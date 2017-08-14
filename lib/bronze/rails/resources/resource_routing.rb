# lib/bronze/rails/resources/resource_routing.rb

require 'bronze/rails/resources'
require 'bronze/rails/services/routes_service'

module Bronze::Rails::Resources
  # Decorator class for determining routing paths for a Rails resource.
  class ResourceRouting
    # @param resource [Bronze::Rails::Resources::Resource] The resource to
    #   update.
    def initialize resource
      @resource = resource
    end # constructor

    # @return [Bronze::Rails::Resources::Resource] The resource to update.
    attr_reader :resource

    # Generates the relative URL for the interface for editing an existing
    # entity for the resource, which typically corresponds to the GET #edit
    # action.
    #
    # @param ancestors [Array] The parent resource(s) or id(s), if any, that
    #   the resource is nested within in the route definitions.
    #
    # @return [String] The URL to the resource relative to the site root.
    def edit_resource_path *ancestors, object
      helper_name =
        "edit_#{path_prefix}#{resource.singular_resource_name}_path"

      routes_service.send helper_name, *ancestors, object
    end # method new_resource_path

    # Generates the relative URL for the interface for creating a new entity
    # for the resource, which typically corresponds to the GET #new action.
    #
    # @param ancestors [Array] The parent resource(s) or id(s), if any, that
    #   the resource is nested within in the route definitions.
    #
    # @return [String] The URL to the resource relative to the site root.
    def new_resource_path *ancestors
      helper_name =
        "new_#{path_prefix}#{resource.singular_resource_name}_path"

      routes_service.send helper_name, *ancestors
    end # method new_resource_path

    # Generates the relative URL for accessing the parent resource collection,
    # or the root path if there is no parent resource.
    #
    # @param ancestors [Array] The parent resource(s) or id(s), if any, that
    #   the resource is nested within in the route definitions.
    #
    # @return [String] The URL to the resource relative to the site root.
    #
    # @see #resources_path
    def parent_resources_path *ancestors
      parent = resource.parent_resources.last

      return routes_service.root_path unless parent

      routing = Bronze::Rails::Resources::ResourceRouting.new(parent)

      routing.resources_path(*ancestors)
    end # method parent_resources_path

    # Generates the relative URL for accessing the specified item in the
    # resource, which typically corresponds to the GET #show, PUT or PATCH
    # #update, and DELETE #destroy actions.
    #
    # @param ancestors [Array] The parent resource(s) or id(s), if any, that
    #   the resource is nested within in the route definitions.
    # @param resource [Object] The resource or resource id.
    #
    # @return [String] The URL to the resource relative to the site root.
    def resource_path *ancestors, object
      helper_name = "#{path_prefix}#{resource.singular_resource_name}_path"

      routes_service.send helper_name, *ancestors, object
    end # method resource_path

    # Generates the relative URL for accessing the resource collection, which
    # typically corresponds to the GET #index and POST #create actions.
    #
    # @param ancestors [Array] The parent resource(s) or id(s), if any, that
    #   the resource is nested within in the route definitions.
    #
    # @return [String] The URL to the resource relative to the site root.
    def resources_path *ancestors
      helper_name = "#{path_prefix}#{resource.plural_resource_name}_path"

      routes_service.send helper_name, *ancestors
    end # method resources_path

    private

    def path_prefix
      @path_prefix ||=
        resource.
        namespaces.
        map { |hsh| tools.string.singularize(hsh[:name]) }.
        reduce('') { |str, name| str << name << '_' }
    end # method path_prefix

    def routes_service
      Bronze::Rails::Services::RoutesService.instance
    end # method routes_service

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
