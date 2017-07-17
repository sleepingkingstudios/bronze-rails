# lib/bronze/rails/resources/resource_strategy.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  module ResourceStrategy
    class << self
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