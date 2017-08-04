# lib/bronze/rails/resources/resource/routing.rb

require 'bronze/rails/resources'
require 'bronze/rails/services/routes_service'

module Bronze::Rails::Resources
  class Resource
    # Functionality for determining routing paths for a Rails resource.
    module Routing
      # Generates the relative URL for the interface for editing an existing
      # entity for the resource, which typically corresponds to the GET #edit
      # action.
      #
      # @param ancestors [Array] The parent resource(s) or id(s), if any, that
      #   the resource is nested within in the route definitions.
      #
      # @return [String] The relative URL to the resource.
      def edit_resource_path *ancestors, resource
        helper_name = "edit_#{path_prefix}#{singular_resource_name}_path"

        routes_service.send helper_name, *ancestors, resource
      end # method new_resource_path

      # Generates the relative URL for the interface for creating a new entity
      # for the resource, which typically corresponds to the GET #new action.
      #
      # @param ancestors [Array] The parent resource(s) or id(s), if any, that
      #   the resource is nested within in the route definitions.
      #
      # @return [String] The relative URL to the resource.
      def new_resource_path *ancestors
        helper_name = "new_#{path_prefix}#{singular_resource_name}_path"

        routes_service.send helper_name, *ancestors
      end # method new_resource_path

      # Generates the relative URL for accessing the specified item in the
      # resource, which typically corresponds to the GET #show, PUT or PATCH
      # #update, and DELETE #destroy actions.
      #
      # @param ancestors [Array] The parent resource(s) or id(s), if any, that
      #   the resource is nested within in the route definitions.
      # @param resource [Object] The resource or resource id.
      #
      # @return [String] The relative URL to the resource.
      def resource_path *ancestors, resource
        helper_name = "#{path_prefix}#{singular_resource_name}_path"

        routes_service.send helper_name, *ancestors, resource
      end # method resource_path

      # Generates the relative URL for accessing the root path for the resource
      # collection, which typically corresponds to the GET #index and POST
      # #create actions.
      #
      # @param ancestors [Array] The parent resource(s) or id(s), if any, that
      #   the resource is nested within in the route definitions.
      #
      # @return [String] The relative URL to the resource.
      def resources_path *ancestors
        helper_name = "#{path_prefix}#{plural_resource_name}_path"

        routes_service.send helper_name, *ancestors
      end # method resources_path

      private

      def path_prefix
        @path_prefix ||=
          namespaces.
          map { |hsh| tools.string.singularize(hsh[:name]) }.
          reduce('') { |str, name| str << name << '_' }
      end # method path_prefix

      def routes_service
        Bronze::Rails::Services::RoutesService.instance
      end # method routes_service
    end # module
  end # class
end # module
