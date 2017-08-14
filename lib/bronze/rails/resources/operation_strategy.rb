# lib/bronze/rails/resources/operation_strategy.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  # Strategy class for mapping a resource class to an operation builder that can
  # be used to perform resourceful actions.
  module OperationStrategy
    class << self
      # Maps the given resource class to an operation builder conforming to a
      # standard interface.
      #
      # @param resource_class [Class] The class corresponding to the resource.
      #
      # @return [Bronze::Operations::OperationBuilder] An operation builder.
      def for resource_class
        strategy =
          constant_operations_strategy(resource_class) ||
          entity_operations_strategy(resource_class)

        return strategy if strategy

        raise ArgumentError,
          "unknown builder strategy for #{resource_class.inspect}"
      end # class method for

      private

      def constant_operations_strategy resource_class
        return unless resource_class.respond_to?(:const_defined?)
        return unless resource_class.const_defined?(:Operations)

        resource_class.const_get(:Operations)
      end # class method constant_operations_strategy

      def entity_operations_strategy resource_class
        return unless resource_class
        return unless defined?(Bronze::Entities::Entity)
        return unless resource_class < Bronze::Entities::Entity

        require 'bronze/entities/operations/entity_operation_builder'

        Bronze::Entities::Operations::EntityOperationBuilder.
          new(resource_class) do
            define_entity_operations
          end # strategy
      end # class method entity_operations_strategy
    end # eigenclass
  end # module
end # module
