# lib/bronze/rails/resources/resource.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/names'
require 'bronze/rails/services/routes_service'

# rubocop:disable Metrics/ClassLength

module Bronze::Rails::Resources
  # Object representing a Rails resource. Provides methods to query properties
  # such as resourceful routes and template paths.
  class Resource
    include Bronze::Rails::Resources::Resource::Base
    include Bronze::Rails::Resources::Resource::Names

    # @param resource_class [Class] The base class representing instances of the
    #   resource.
    # @param resource_options [Hash] Additional options for the resource.
    def initialize resource_class, resource_options = {}
      super

      process_options
    end # constructor

    # @return [Array<Resource>] The parent resource definitions.
    attr_reader :parent_resources

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

    # The name of the controller for the resource in underscored format.
    #
    # @return [String] The controller name.
    def controller_name
      @controller_name ||=
        begin
          name = @resource_options.fetch(:controller_name, '')
          name = name.empty? ? plural_resource_name : name
          name = tools.string.underscore(name)
          name.sub(/_controller\z/, '')
        end # controller_name
    end # method controller_name

    # Returns the default path of the template for the edit action.
    #
    # @return [String] The template path.
    def edit_template
      template :edit
    end # method edit_template

    # Finds the parent resource with the given resource key or association key.
    #
    # @return [Resource] The requested resource, or nil if the resource is not
    #   found.
    def find_parent_resource resource_key
      expected = resource_key.to_s

      parent_resources.find do |parent|
        parent.association_name == expected ||
          parent.plural_resource_name == expected
      end # find
    end # method find_parent_resource

    # The foreign key of the association from the root resource.
    #
    # @return [Symbol] The foreign key.
    def foreign_key
      @resource_options.fetch :foreign_key,
        :"#{tools.string.singularize association_name.to_s}_id"
    end # method foreign_keys

    # Returns the default path of the template for the index action.
    #
    # @return [String] The template path.
    def index_template
      template :index
    end # method index_template

    # Returns the default path of the template for the new action.
    #
    # @return [String] The template path.
    def new_template
      template :new
    end # method new_template

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

    # Returns the default path of the template for the show action.
    #
    # @return [String] The template path.
    def show_template
      template :show
    end # method show_template

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

    # Returns the default path of the template for the given action.
    #
    # @param action [String, Symbol] The name of the action.
    #
    # @return [String] The template path.
    def template action
      @namespaces.
        reduce('') { |str, name| str << name << '/' } <<
        controller_name << '/' <<
        action.to_s
    end # method template

    private

    def build_parent_resource ancestor, ancestors
      if ancestor.key?(:resource_definition)
        @parent_resources << ancestor[:resource_definition]

        return ancestor[:resource_definition]
      end # if

      options = ancestor.dup.merge(:ancestors => ancestors)
      klass   = options.delete(:class)
      parent  = self.class.new(klass, options)

      @parent_resources << parent

      parent
    end # method build_parent_resource

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
          @ancestor_names.
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

        @namespaces << name if ancestor[:type] == :namespace
      end # each

      build_parent_resources ancestors
    end # method process_options

    def routes
      Bronze::Rails::Services::RoutesService.instance
    end # method routes
  end # class
end # module

# rubocop:enable Metrics/ClassLength
