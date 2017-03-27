# lib/bronze/rails/responders/render_view_responder.rb

require 'bronze/rails/responders/messages'
require 'bronze/rails/responders/responder'
require 'bronze/rails/services/routes_service'

module Bronze::Rails::Responders
  # rubocop:disable Metrics/ClassLength

  # Responder for the omakase Rails behavior, e.g. an application or action that
  # renders a Rails template or redirects to another page within the
  # application.
  class RenderViewResponder < Responder
    include Bronze::Rails::Responders::Messages

    # @param render_context [Object] The object to which render and redirect_to
    #   calls are delegated.
    # @param resource_definition [Resource] The definition of the primary
    #   resource.
    def initialize render_context, resource_definition, options = {}
      @render_context = render_context

      super resource_definition, options
    end # constructor

    # @return [Object] The object to which render and redirect_to calls are
    #   delegated.
    attr_reader :render_context

    # Either renders the requested template or redirects to the requested path.
    #
    # @param operation [Bronze::Operations::Operation] The operation performed
    #   by the action, if any.
    # @param action [String] The name of the performed action.
    def call operation = nil, action:
      if operation
        status      = operation.success? ? 'success' : 'failure'
        helper_name = "respond_to_#{action}_#{status}"
      else
        helper_name = "respond_to_#{action}"
      end # if-else

      send helper_name, operation
    end # method call

    private

    def build_associations_hash
      resources      = @options.fetch(:resources, {})
      resource_names = @options.fetch(:resource_names, [])

      @resource_definition.parent_resources.each do |parent_resource|
        resource_names << parent_resource.parent_key
      end # each

      resource_names.each.with_object({}) do |resource_name, hsh|
        name = resource_name.intern

        hsh[name] = resources[name]
      end # each
    end # method build_associations_hash

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def build_errors operation
      default_key = resource_definition.default_resource_key
      plural_key  = tools.string.pluralize(default_key.to_s).intern

      return operation.errors if resource_definition.resource_key == default_key

      errors = operation.errors

      if errors.key?(default_key)
        errors[resource_definition.resource_key] = errors.delete(default_key)
      end # if

      if errors.key?(plural_key)
        errors[resource_definition.plural_resource_key] =
          errors.delete(plural_key)
      end # if

      errors
    end # method build_errors
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def build_locals options
      locals = {}

      locals.update(options[:resources]) if options.key?(:resources)

      locals[:errors] = options[:errors] if options.key?(:errors)

      locals.update(options[:locals])    if options.key?(:locals)

      locals
    end # method build_locals

    def build_resources_hash operation, many: false
      build_associations_hash.
        update(
          if many
            { @resource_definition.plural_resource_key => operation.resources }
          else
            { @resource_definition.resource_key => operation.resource }
          end # if-else
        ) # end update
    end # method build_resources_hash

    def options_for_invalid_resource operation
      {
        :http_status => :unprocessable_entity,
        :resources   => build_resources_hash(operation),
        :errors      => build_errors(operation)
      } # end options
    end # method options_for_invalid_resource

    def options_for_valid_resource operation
      {
        :resources   => build_resources_hash(operation),
        :errors      => []
      } # end options
    end # method options_for_valid_resource

    def redirect_to redirect_path, options = {}
      options.fetch(:messages, []).
        each { |key, value| set_flash key, value }

      render_context.redirect_to(redirect_path)
    end # method

    def render_template template, options
      status = options.fetch(:http_status, :ok)
      locals = build_locals options

      options.fetch(:messages, []).
        each { |key, value| set_flash key, value, :now => true }

      render_context.render(
        :status   => status,
        :template => template,
        :locals   => locals
      ) # end render
    end # method render_template

    def respond_to_create_failure operation
      options =
        options_for_invalid_resource(operation).
        update(
          :locals => {
            :form_action => resources_path,
            :form_method => :post
          }, # end locals
          :messages => { :warning => build_message(:create, :failure) }
        ) # end update

      render_template @resource_definition.new_template, options
    end # method respond_to_create_failure

    def respond_to_create_success operation
      messages = { :success => build_message(:create, :success) }

      redirect_to resource_path(operation.resource), :messages => messages
    end # method respond_to_create_success

    def respond_to_destroy_failure _operation
      messages = { :warning => build_message(:destroy, :failure) }

      redirect_to(resources_path, :messages => messages)
    end # method respond_to_destroy_failure

    def respond_to_destroy_success _operation
      messages = { :danger => build_message(:destroy, :success) }

      redirect_to(resources_path, :messages => messages)
    end # method respond_to_destroy_success

    def respond_to_edit_failure _operation
      messages = { :warning => build_message(:edit, :failure) }

      redirect_to(resources_path, :messages => messages)
    end # method respond_to_edit_failure

    def respond_to_edit_success operation
      options =
        options_for_valid_resource(operation).
        update(
          :locals => {
            :form_action => resource_path(operation.resource),
            :form_method => :patch
          } # end locals
        ) # end update

      render_template @resource_definition.edit_template, options
    end # method respond_to_edit_success

    def respond_to_index_failure _operation
      parent        = @resource_definition.parent_resources.last
      redirect_path =
        if parent
          parent.resources_path(*ancestors[0...-1])
        else
          Bronze::Rails::Services::RoutesService.instance.root_path
        end # if-else

      messages = { :warning => build_message(:index, :failure) }

      redirect_to(redirect_path, :messages => messages)
    end # method respond_to_index_failure

    def respond_to_index_success operation
      options =
        { :resources => build_resources_hash(operation, :many => true) }

      render_template @resource_definition.index_template, options
    end # method respond_to_index_success

    def respond_to_new_failure _operation
      messages = { :warning => build_message(:new, :failure) }

      redirect_to(resources_path, :messages => messages)
    end # method respond_to_new_failure

    def respond_to_new_success operation
      options =
        options_for_valid_resource(operation).
        update(
          :locals => {
            :form_action => resources_path,
            :form_method => :post
          } # end locals
        ) # end update

      render_template @resource_definition.new_template, options
    end # method respond_to_new_success

    def respond_to_not_found _operation
      messages = { :warning => build_message(:not_found) }

      redirect_to(resources_path, :messages => messages)
    end # method respond_to_not_found

    def respond_to_show_failure _operation
      messages = { :warning => build_message(:show, :failure) }

      redirect_to(resources_path, :messages => messages)
    end # method respond_to_show_failure

    def respond_to_show_success operation
      options = { :resources => build_resources_hash(operation) }

      render_template @resource_definition.show_template, options
    end # method respond_to_show_success

    def respond_to_update_failure operation
      options =
        options_for_invalid_resource(operation).
        update(
          :locals => {
            :form_action => resource_path(operation.resource),
            :form_method => :patch
          }, # end locals
          :messages => { :warning => build_message(:update, :failure) }
        ) # end update

      render_template @resource_definition.edit_template, options
    end # method respond_to_update_failure

    def respond_to_update_success operation
      messages = { :success => build_message(:update, :success) }

      redirect_to resource_path(operation.resource), :messages => messages
    end # method respond_to_update_success

    def set_flash key, message, now: false
      flash    = render_context.flash
      flash    = flash.now if now

      (flash[key] ||= []) << message
    end # method set_flash
  end # class

  # rubocop:enable Metrics/ClassLength
end # module
