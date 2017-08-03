# lib/bronze/rails/resources/resource.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/names'
require 'bronze/rails/resources/resource/templates'
require 'bronze/rails/services/routes_service'

module Bronze::Rails::Resources
  # Object representing a Rails resource. Provides methods to query properties
  # such as resourceful routes and template paths.
  class Resource
    include Bronze::Rails::Resources::Resource::Base
    include Bronze::Rails::Resources::Resource::Names
    include Bronze::Rails::Resources::Resource::Templates

    # @param resource_class [Class] The base class representing instances of the
    #   resource.
    # @param resource_options [Hash] Additional options for the resource.
    def initialize resource_class, resource_options = {}
      super

      process_options
    end # constructor

    # @return [Array<String>] The names of parent resources and/or namespaces,
    #   from outermost to innermost.
    attr_reader :namespaces

    # @see #association_key
    #
    # @return [Symbol] The association name.
    def association_key
      association_name.intern
    end # method association_key

    # The name of the association from the root resource.
    #
    # @return [String] The association name.
    def association_name
      @resource_options.fetch(:association_name, plural_resource_name).to_s
    end # method association_name

    # The foreign key of the association from the root resource.
    #
    # @return [Symbol] The foreign key.
    def foreign_key
      @resource_options.fetch :foreign_key,
        :"#{tools.string.singularize association_name.to_s}_id"
    end # method foreign_keys

    # @return [Array<Resource>] The parent resource definitions.
    def parent_resources
      namespaces.
        select { |hsh| hsh[:type] == :resource }.
        map { |hsh| hsh[:resource] }
    end # method parent_resources

    # The primary key of the resource.
    #
    # @return [Symbol] The primary key.
    def primary_key
      @resource_options.fetch :primary_key, :"#{resource_name}_id"
    end # method primary_key

    # @return [String] The relative path to the resource.
    def resource_path *ancestors, resource_or_id
      helper_name = "#{path_prefix}#{resource_name}_path"

      routes.send helper_name, *ancestors, resource_or_id
    end # method resources_path

    # @return [String] The relative path to the resource index.
    def resources_path *ancestors
      helper_name = "#{path_prefix}#{plural_resource_name}_path"

      routes.send helper_name, *ancestors
    end # method resources_path

    # @see #singular_association_name
    #
    # @return [Symbol] The association name.
    def singular_association_key
      singular_association_name.intern
    end # method singular_association_key
    alias_method :parent_key, :singular_association_key

    # Returns the singular form of the association name, such as when referring
    # to the instance of a parent resource.
    #
    # @return [String] The association name.
    def singular_association_name
      tools.string.singularize(association_name)
    end # method singular_association_name
    alias_method :parent_name, :singular_association_name

    private

    # rubocop:disable Metrics/AbcSize
    def build_parent_resource ancestor, ancestors
      if ancestor.key?(:resource_definition)
        @parent_resources << ancestor[:resource_definition]

        return ancestor[:resource_definition]
      end # if

      options = ancestor.dup.merge(:ancestors => ancestors)
      parent  = self.class.new(options.delete(:class), options)

      namespaces.
        find { |hsh| hsh[:name] == ancestor[:name] }.
        update(:resource => parent)

      parent
    end # method build_parent_resource
    # rubocop:enable Metrics/AbcSize

    def build_parent_resources ancestors
      @parent_resources = []

      ancestors.each.with_index do |ancestor, index|
        next unless ancestor[:type] == :resource

        parent = build_parent_resource ancestor, ancestors[0...index]

        ancestor[:resource_definition] = parent
      end # each
    end # method build_parent_resources

    def path_prefix
      @path_prefix ||=
        begin
          namespaces.
            map { |hsh| hsh[:name] }.
            map { |name| tools.string.singularize(name) }.
            reduce('') { |str, name| str << name << '_' }
        end # prefix
    end # method path_prefix

    def process_options
      @namespaces     = []
      @ancestor_names = []
      ancestors       = resource_options.fetch(:ancestors, [])

      ancestors.each do |ancestor|
        name = ancestor[:name].to_s

        @ancestor_names << name

        @namespaces << { :name => ancestor[:name], :type => ancestor[:type] }
      end # each

      build_parent_resources ancestors
    end # method process_options

    def routes
      Bronze::Rails::Services::RoutesService.instance
    end # method routes
  end # class
end # module
