# lib/bronze/rails/resources/resource.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource/associations'
require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/names'
require 'bronze/rails/resources/resource/routing'
require 'bronze/rails/resources/resource/templates'
require 'bronze/rails/services/routes_service'

module Bronze::Rails::Resources
  # Object representing a Rails resource. Provides methods to query properties
  # such as resourceful routes and template paths.
  class Resource
    include Bronze::Rails::Resources::Resource::Base
    include Bronze::Rails::Resources::Resource::Associations
    include Bronze::Rails::Resources::Resource::Names
    include Bronze::Rails::Resources::Resource::Routing
    include Bronze::Rails::Resources::Resource::Templates

    # @param resource_class [Class] The base class representing instances of the
    #   resource.
    # @param resource_options [Hash] Additional options for the resource.
    def initialize resource_class, resource_options = {}
      super

      process_options
    end # constructor

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
  end # class
end # module
