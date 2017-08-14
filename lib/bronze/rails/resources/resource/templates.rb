# lib/bronze/rails/resources/resource/templates.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  class Resource
    # Decorator class for determining template paths for a Rails resource.
    class Templates
      # @param resource [Bronze::Rails::Resources::Resource] The resource to
      #   update.
      def initialize resource
        @resource = resource
      end # constructor

      # @return [Bronze::Rails::Resources::Resource] The resource to update.
      attr_reader :resource

      # Returns the default path of the template for the edit action.
      #
      # @return [String] The template path.
      def edit_template
        template :edit
      end # method edit_template

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

      # Returns the default path of the template for the show action.
      #
      # @return [String] The template path.
      def show_template
        template :show
      end # method show_template

      # Returns the default path of the template for the given action.
      #
      # @param action [String, Symbol] The name of the action.
      #
      # @return [String] The template path.
      def template action_name
        resource.
          namespaces.
          select { |hsh| hsh[:type] == :namespace }.
          map { |hsh| hsh[:name] }.
          push(resource.controller_name).
          push(action_name).
          join '/'
      end # method template
    end # module
  end # class
end # module
