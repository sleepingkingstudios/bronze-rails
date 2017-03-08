# lib/bronze/rails/resources/resources_controller.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

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

    delegate :resource_definition, :to => :class

    delegate \
      :resource_class,
      :resource_name,
      :to        => :resource_definition,
      :allow_nil => true

    # POST /path/to/resources
    def create
      responder.call(build_response create_resource)
    end # method create

    # GET /path/to/resources/:id/edit
    def edit
      responder.call(build_response edit_resource)
    end # method edit

    # GET /path/to/resources
    def index
      responder.call(build_response index_resources)
    end # method index

    # GET /path/to/resources/new
    def new
      responder.call(build_response new_resource)
    end # method new

    # GET /path/to/resources/:id
    def show
      responder.call(build_response show_resource)
    end # method show

    private

    ############################################################################
    ###                               Actions                                ###
    ############################################################################

    def create_resource
      build_resource(resource_class, resource_params).
        then { |operation| validate_resource(operation.resource) }.
        then { |operation| insert_resource(operation.resource) }
    end # method create_resource

    def edit_resource
      find_resource resource_class, params[:id]
    end # method edit_resource

    def index_resources
      find_matching_resources resource_class, filter_params
    end # method index_resources

    def new_resource
      build_resource resource_class, resource_params
    end # method new_resource

    def show_resource
      find_resource resource_class, params[:id]
    end # method show_resource

    ############################################################################
    ###                             Operations                               ###
    ############################################################################

    def build_resource resource_class, resource_params
      Patina::Operations::Entities::BuildOneOperation.new(
        resource_class
      ).execute(resource_params)
    end # method build_resource

    def find_matching_resources resource_class, filter_params
      Patina::Operations::Entities::FindMatchingOperation.new(
        repository,
        resource_class
      ).execute(filter_params)
    end # method find_matching_resources

    def find_resource resource_class, resource_id
      Patina::Operations::Entities::FindOneOperation.new(
        repository,
        resource_class
      ).execute(resource_id)
    end # method find_resource

    def insert_resource resource
      Patina::Operations::Entities::InsertOneOperation.new(
        repository,
        resource_class
      ).execute(resource)
    end # method insert_resource

    def validate_resource resource
      Patina::Operations::Entities::ValidateOneOperation.new.execute(resource)
    end # method validate_resource

    ############################################################################
    ###                               Helpers                                ###
    ############################################################################

    def build_response operation
      response_builder.build_response operation, :action => action_name
    end # method build_response

    def coerce_attributes resource_class, attributes
      attributes.each do |attr_name, value|
        attribute = resource_class.attributes[attr_name.intern]

        if attribute && attribute.object_type == Integer && value.is_a?(String)
          attributes[attr_name] = value.to_i
        end # if
      end # each

      attributes
    end # method coerce_attributes

    def filter_params
      whitelist = %i(matching)

      params.
        permit(whitelist).
        tap do |hsh|
          whitelist.each do |key|
            hsh[key] = params.key?(key) ? params[key].permit! : {}
          end # each
        end. # tap
        to_h
    end # method filter_params

    def permitted_attributes
      []
    end # method permitted_attributes

    def resource_params
      hsh =
        params.
        permit(resource_name => permitted_attributes).
        fetch(resource_name, {}).
        to_h

      coerce_attributes(resource_class, hsh)
    end # method resource_params

    def responder
      @responder ||= Bronze::Rails::Responders::RenderViewResponder.new(self)
    end # method responder

    def response_builder resource_definition = nil
      resource_definition ||= self.resource_definition

      Bronze::Rails::Resources::ResourcefulResponseBuilder.new(
        resource_definition
      ) # end response builder
    end # method response_builder
  end # module
end # module

# rubocop:enable Metrics/ModuleLength
