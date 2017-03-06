# lib/bronze/rails/resources/resources_controller.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/rails/resources/resource'

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
  end # module
end # module
