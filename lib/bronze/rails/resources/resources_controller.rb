# lib/bronze/rails/resources/resources_controller.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/entities'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resourceful_response_builder'
require 'bronze/rails/responders/render_view_responder'

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

    delegate :resource_class, :to => :resource_definition, :allow_nil => true

    def index
      responder.call(build_response index_resources)
    end # method index

    private

    ############################################################################
    ###                             Operations                               ###
    ############################################################################

    def find_matching_resources resource_class, filter_params
      Patina::Operations::Entities::FindMatchingOperation.new(
        repository,
        resource_class
      ).execute(filter_params)
    end # method find_matching_resources

    def index_resources
      find_matching_resources resource_class, filter_params
    end # method index_resources

    ############################################################################
    ###                               Helpers                                ###
    ############################################################################

    def build_response operation
      response_builder.build_response operation, :action => action_name
    end # method build_response

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
