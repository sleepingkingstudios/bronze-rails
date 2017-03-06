# lib/bronze/rails/resources/resourceful_response_builder.rb

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource'
require 'bronze/rails/services/routes_service'

# rubocop:disable Metrics/ClassLength

module Bronze::Rails::Resources
  # Builds response options for resourceful actions that can be passed in to a
  # responder object.
  class ResourcefulResponseBuilder
    include SleepingKingStudios::Tools::Toolbox::Delegator

    # @param resource_definition [Resource] The definition of the primary
    #   resource.
    # @param resources [Hash] Additional resources, such as the values of parent
    #   or child resources.
    def initialize resource_definition, resources = {}
      @resource_definition = resource_definition
      @resources           = resources
    end # constructor

    delegate \
      :edit_template,
      :index_template,
      :new_template,
      :parent_resources,
      :plural_resource_key,
      :plural_resource_name,
      :show_template,
      :resource_key,
      :resource_name,
      :to => :@resource_definition

    # Builds response options for a missing resource.
    #
    # @return [Hash] The response options
    def build_not_found_response
      build_failure_response
    end # method build_not_found_response

    # Builds response options based on the given operation and action.
    #
    # @param operation [Bronze::Operations::Operation] The called operation.
    # @param action [String, Symbol] The name of the called action.
    #
    # @return [Hash] The response options
    def build_response operation, action:
      status      = operation.success? ? 'success' : 'failure'
      helper_name = "build_#{action}_#{status}_response"

      send helper_name, operation
    end # method build_response

    private

    def ancestors
      @resource_definition.parent_resources.map do |ancestor|
        @resources[ancestor.parent_key]
      end # map
    end # method ancestors

    def build_create_failure_response operation
      build_invalid_resource_response(operation).merge(
        build_new_form_response
      ) # end options
    end # method build_create_failure_response

    def build_create_success_response operation
      build_form_success_response operation
    end # method build_create_success_response

    def build_destroy_failure_response _operation
      build_failure_response
    end # method build_destroy_failure_response

    def build_destroy_success_response _operation
      build_failure_response
    end # method build_destroy_success_response

    def build_edit_failure_response _operation
      build_failure_response
    end # method build_edit_failure_response

    def build_edit_form_response operation
      {
        :template => edit_template,
        :locals   => {
          :form_action => resource_path(operation.resource),
          :form_method => :patch
        } # end locals
      } # end options
    end # method build_edit_form_response

    def build_edit_success_response operation
      build_edit_form_response(operation).merge(
        :resources => resources_hash(operation),
        :errors    => []
      ) # end options
    end # method build_edit_success_response

    def build_failure_response
      { :redirect_path => resources_path }
    end # method build_failure_response

    def build_form_success_response operation
      { :redirect_path => resource_path(operation.resource) }
    end # method build_form_success_response

    def build_index_failure_response _operation
      parent        = @resource_definition.parent_resources.last
      redirect_path =
        if parent
          parent.resources_path(*ancestors[0...-1])
        else
          Bronze::Rails::Services::RoutesService.instance.root_path
        end # if-else

      { :redirect_path => redirect_path }
    end # method build_index_failure_response

    def build_index_success_response operation
      {
        :template  => index_template,
        :resources => resources_hash(operation, :many => true)
      } # end options
    end # method build_index_success_response

    def build_invalid_resource_response operation
      {
        :http_status => :unprocessable_entity,
        :resources   => resources_hash(operation),
        :errors      => operation.errors
      } # end options
    end # method build_invalid_resource_response

    def build_new_failure_response _operation
      build_failure_response
    end # method build_new_failure_response

    def build_new_form_response
      {
        :template => new_template,
        :locals   => {
          :form_action => resources_path,
          :form_method => :post
        } # end locals
      } # end options
    end # method build_new_form_response

    def build_new_success_response operation
      build_new_form_response.merge(
        :resources => resources_hash(operation),
        :errors    => []
      ) # end options
    end # method build_edit_success_response

    def build_show_failure_response _operation
      build_failure_response
    end # method build_show_failure_response

    def build_show_success_response operation
      {
        :template  => show_template,
        :resources => resources_hash(operation)
      } # end options
    end # method build_show_success_response

    def build_update_failure_response operation
      build_invalid_resource_response(operation).merge(
        build_edit_form_response(operation)
      ) # end options
    end # method build_update_failure_operation

    def build_update_success_response operation
      build_form_success_response operation
    end # method build_update_success_response

    def resource_path resource
      @resource_definition.resource_path(*ancestors, resource)
    end # method resource_path

    def resources_hash operation, many: false
      if many
        { plural_resource_key => operation.resources }
      else
        { resource_key => operation.resource }
      end # if-else
    end # method resources_hash

    def resources_path
      @resource_definition.resources_path(*ancestors)
    end # method resources_path
  end # class
end # module

# rubocop:enable Metrics/ClassLength
