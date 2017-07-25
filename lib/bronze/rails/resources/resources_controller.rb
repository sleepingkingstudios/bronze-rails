# lib/bronze/rails/resources/resources_controller.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/operations/identity_operation'
require 'bronze/operations/null_operation'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource_strategy'
require 'bronze/rails/responders/render_view_responder'

# rubocop:disable Metrics/ModuleLength

module Bronze::Rails::Resources
  # Mixin for implementing standard Rails resourceful functionality in a
  # controller.
  module ResourcesController
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include SleepingKingStudios::Tools::Toolbox::Delegator

    # Class methods to define when including ResourcesController in a class.
    module ClassMethods
      # Configures the controller to operate on the given resource.
      #
      # @param resource_class [Class] The base class representing instances of
      #   the resource.
      # @param resource_options [Hash] Additional options for the resource.
      def resource resource_class, resource_options = {}
        @resource_definition =
          Bronze::Rails::Resources::Resource.new(
            resource_class,
            resource_options
          ) # end definition
      end # class method resource

      # @return [Resource] The definition of the primary resource.
      attr_reader :resource_definition
    end # module

    def self.included other
      super

      return unless other.respond_to?(:before_action)

      other.before_action :require_parent_resources

      other.before_action :require_primary_resource,
        :only => %i(show edit update destroy)
    end # class method included

    delegate :resource_definition, :to => :class

    delegate \
      :resource_class,
      :to        => :resource_definition,
      :allow_nil => true

    # POST /path/to/resources
    def create
      build_responder.call(create_resource, :action => :create)
    end # method create

    # DELETE /path/to/resources/:id
    def destroy
      build_responder.call(destroy_resource, :action => :destroy)
    end # method destroy

    # GET /path/to/resources/:id/edit
    def edit
      build_responder.call(edit_resource, :action => :edit)
    end # method edit

    # GET /path/to/resources
    def index
      build_responder.call(index_resources, :action => :index)
    end # method index

    # GET /path/to/resources/new
    def new
      build_responder.call(new_resource, :action => :new)
    end # method new

    # GET /path/to/resources/:id
    def show
      build_responder.call(show_resource, :action => :show)
    end # method show

    # PATCH /path/to/resources/:id
    def update
      build_responder.call(update_resource, :action => :update)
    end # method update

    private

    ############################################################################
    ###                               Actions                                ###
    ############################################################################

    def create_resource
      operation_builder.
        build_and_insert_one(repository).
        else { |op| map_errors(op) }.
        execute(resource_params)
    end # method create_resource

    def destroy_resource
      operation_builder.
        delete_one(repository).
        else { |op| map_errors(op) }.
        execute(primary_resource)
    end # method destroy_resource

    def edit_resource
      Bronze::Operations::IdentityOperation.new.
        then { |op| assign_associations(*op.result) }.
        execute(primary_resource)
    end # method edit_resource

    def index_resources
      operation_builder.
        find_matching(repository).
        then { |op| assign_associations(*op.result) }.
        execute(filter_params)
    end # method index_resources

    def new_resource
      operation_builder.
        build_one.
        execute(resource_params)
    end # method new_resource

    def show_resource
      Bronze::Operations::IdentityOperation.new.
        then { |op| assign_associations(op.result) }.
        execute(primary_resource)
    end # method show_resource

    def update_resource
      operation_builder.
        assign_and_update_one(repository).
        else { |op| map_errors(op) }.
        execute(primary_resource, resource_params)
    end # method update_resource

    ############################################################################
    ###                             Callbacks                                ###
    ############################################################################

    # rubocop:disable Metrics/AbcSize
    def require_parent_resources
      resource_definition.parent_resources.reduce(null_operation.execute) \
      do |last_operation, parent_definition|
        last_operation.then do
          resource_id = params[parent_definition.primary_key]

          require_one(parent_definition).execute(resource_id)
        end.then do |operation|
          resources[parent_definition.parent_key] = operation.result
        end # then
      end. # reduce
        execute
    end # method require_parent_resources
    # rubocop:enable Metrics/AbcSize

    def require_primary_resource
      require_one(resource_definition).
        then do |operation|
          resources[resource_definition.resource_key] = operation.result
        end. # then
        execute(params[:id])
    end # method require_primary_resource

    ############################################################################
    ###                             Operations                               ###
    ############################################################################

    def require_one resource_definition
      builder = operation_builder(resource_definition)

      builder::FindOne.
        new(repository).
        else do
          responder = build_responder(resource_definition)

          responder.call(:action => :not_found)
        end # else
    end # method require_one

    ############################################################################
    ###                               Helpers                                ###
    ############################################################################

    def assign_associations *primary_resources
      parent_definition = resource_definition.parent_resources.last

      Array(primary_resources).each do |primary_resource|
        next unless parent_definition

        primary_resource.send(
          :"#{parent_definition.parent_name}=",
          resources[parent_definition.parent_key]
        ) # end set association
      end # each
    end # method assign_associations

    def build_responder resource_definition = nil
      resource_definition ||= self.resource_definition

      Bronze::Rails::Responders::RenderViewResponder.new(
        self,
        resource_definition,
        :resources      => resources,
        :resource_names => resource_names
      ) # end responder
    end # method build_responder

    def coerce_attributes resource_class, attributes
      attributes.each do |attr_name, value|
        attribute = resource_class.attributes[attr_name.intern]

        if attribute && attribute.object_type == Integer && value.is_a?(String)
          attributes[attr_name] = value.to_i
        end # if
      end # each

      attributes
    end # method coerce_attributes

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def filter_params
      whitelist = %i(matching)
      filter    =
        whitelist.each.with_object({}) do |key, hsh|
          hsh[key] = params.key?(key) ? params[key].permit!.to_h : {}
        end # each

      parent_definition = resource_definition.parent_resources.last
      if parent_definition
        filter[:matching][parent_definition.foreign_key.to_s] =
          params[parent_definition.primary_key]
      end # if

      filter
    end # method filter_params
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def map_errors operation
      return operation unless operation.errors && !operation.errors.empty?

      resource_key = resource_definition.resource_key
      original_key = resource_definition.resource_class.name.split('::').last
      original_key = tools.string.underscore(original_key).intern

      return operation if resource_key == original_key
      return operation unless operation.errors.key?(original_key)

      operation.errors[resource_key] = operation.errors.delete(original_key)

      operation
    end # method map_error
    # rubocop:enable Metrics/AbcSize

    def null_operation
      Bronze::Operations::NullOperation.new
    end # method null_operation

    def operation_builder resource_definition = nil
      resource_definition ||= self.resource_definition
      resource_class        = resource_definition&.resource_class

      Bronze::Rails::Resources::ResourceStrategy.for(resource_class)
    end # method operation_builder

    def permitted_attributes
      []
    end # method permitted_attributes

    def primary_resource
      resources[resource_definition.resource_key]
    end # method primary_resource

    def resource_names
      []
    end # method resource_names

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def resource_params
      resource_name = resource_definition.resource_name

      hsh =
        params.
        permit(resource_name => permitted_attributes).
        fetch(resource_name, {}).
        to_h

      hsh = coerce_attributes(resource_class, hsh)

      parent_definition = resource_definition.parent_resources.last
      if parent_definition
        hsh[parent_definition.singular_association_key] =
          resources[parent_definition.parent_key]
      end # if

      hsh
    end # method resource_params
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def resources
      @resources ||= {}
    end # method resources

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # module
end # module

# rubocop:enable Metrics/ModuleLength
