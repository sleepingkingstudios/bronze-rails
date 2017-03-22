# lib/bronze/rails/resources/resources_controller.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/operations/null_operation'

require 'patina/operations/entities'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resourceful_response_builder'
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

      other.before_action :require_primary_resource, :only => %i(update destroy)
    end # class method included

    delegate :resource_definition, :to => :class

    delegate \
      :resource_class,
      :resource_name,
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
      build_one(resource_class, resource_params).
        then { |operation| validate_one(operation.resource) }.
        then { |operation| insert_one(resource_class, operation.resource) }
    end # method create_resource

    def destroy_resource
      destroy_one resource_class, primary_resource
    end # method destroy_resource

    def edit_resource
      find_one(resource_class, params[:id]).
        then { |operation| assign_associations(operation.resource) }
    end # method edit_resource

    def index_resources
      find_matching(resource_class, filter_params).
        then { |operation| assign_associations(*operation.resources) }
    end # method index_resources

    def new_resource
      build_one resource_class, resource_params
    end # method new_resource

    def show_resource
      find_one(resource_class, params[:id]).
        then { |operation| assign_associations(operation.resource) }
    end # method show_resource

    def update_resource
      assign_one(primary_resource, resource_params).
        then { |operation| validate_one(operation.resource) }.
        then { |operation| update_one(resource_class, operation.resource) }
    end # method update_resource

    ############################################################################
    ###                             Callbacks                                ###
    ############################################################################

    def require_one resource_definition, resource_id
      find_one(resource_definition.resource_class, resource_id).
        else do
          responder = build_responder(resource_definition)

          responder.call(:action => :not_found)
        end # else
    end # method require_one

    def require_parent_resources
      resource_definition.parent_resources.reduce(null_operation.execute) \
      do |last_operation, parent_definition|
        last_operation.then do
          resource_id = params[parent_definition.primary_key]

          require_one(parent_definition, resource_id)
        end.then do |operation|
          resources[parent_definition.parent_key] = operation.resource
        end # then
      end # reduce
    end # method require_parent_resources

    def require_primary_resource
      require_one(resource_definition, params[:id]).
        then { |operation| @primary_resource = operation.resource }
    end # method require_primary_resource

    ############################################################################
    ###                             Operations                               ###
    ############################################################################

    def assign_one resource, resource_params
      Patina::Operations::Entities::AssignOneOperation.new.
        execute(resource, resource_params)
    end # method assign_one

    def build_one resource_class, resource_params
      Patina::Operations::Entities::BuildOneOperation.new(
        resource_class
      ).execute(resource_params)
    end # method build_one

    def destroy_one resource_class, resource
      Patina::Operations::Entities::DestroyOneOperation.new(
        repository,
        resource_class
      ).execute(resource)
    end # method destroy_one

    def find_matching resource_class, filter_params
      Patina::Operations::Entities::FindMatchingOperation.new(
        repository,
        resource_class
      ).execute(filter_params)
    end # method find_matching

    def find_one resource_class, resource_id
      Patina::Operations::Entities::FindOneOperation.new(
        repository,
        resource_class
      ).execute(resource_id)
    end # method find_one

    def insert_one resource_class, resource
      Patina::Operations::Entities::InsertOneOperation.new(
        repository,
        resource_class
      ).execute(resource)
    end # method insert_one

    def update_one resource_class, resource
      Patina::Operations::Entities::UpdateOneOperation.new(
        repository,
        resource_class
      ).execute(resource)
    end # method insert_one

    def validate_one resource
      Patina::Operations::Entities::ValidateOneOperation.new.execute(resource)
    end # method validate_one

    ############################################################################
    ###                               Helpers                                ###
    ############################################################################

    attr_accessor :primary_resource

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
        :resources => resources
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

      filter =
        params.
        permit(whitelist).
        tap do |hsh|
          whitelist.each do |key|
            hsh[key] = params.key?(key) ? params[key].permit! : {}
          end # each
        end. # tap
        to_h

      parent_definition = resource_definition.parent_resources.last
      if parent_definition
        filter['matching'][parent_definition.foreign_key.to_s] =
          params[parent_definition.primary_key]
      end # if

      filter
    end # method filter_params
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def null_operation
      Bronze::Operations::NullOperation.new
    end # method null_operation

    def permitted_attributes
      []
    end # method permitted_attributes

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def resource_params
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

    def response_builder resource_definition = nil
      resource_definition ||= self.resource_definition

      Bronze::Rails::Resources::ResourcefulResponseBuilder.new(
        resource_definition,
        resources
      ) # end response builder
    end # method response_builder
  end # module
end # module

# rubocop:enable Metrics/ModuleLength
