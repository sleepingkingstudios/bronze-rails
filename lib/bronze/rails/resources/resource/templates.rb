# lib/bronze/rails/resources/resource/templates.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  class Resource
    # Functionality for determining template paths for a Rails resource.
    module Templates
      # The name of the controller for the resource in underscored format.
      #
      # @return [String] The controller name.
      def controller_name
        @controller_name ||=
          if @resource_options.key?(:controller_name)
            tools.string.underscore(@resource_options.fetch(:controller_name)).
              sub(/_controller\z/, '')
          else
            plural_resource_name
          end # if-else
      end # method controller_name

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
        namespaces.
          select { |hsh| hsh[:type] == :namespace }.
          map { |hsh| hsh[:name] }.
          push(controller_name).
          push(action_name).
          join '/'
      end # method template
    end # module
  end # class
end # module
