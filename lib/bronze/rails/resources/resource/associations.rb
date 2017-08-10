# lib/bronze/rails/resources/resource/associations.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  class Resource
    # Functionality for defining and reflecting on resource associations and
    # resource nesting.
    module Associations
      # @see #association_key
      #
      # @return [Symbol] The association name.
      def association_key
        association_name.intern
      end # method association_key
      alias_method :parent_key, :association_key

      # The name of the association, relative to the child resource.
      #
      # @return [String] The association name.
      def association_name
        @resource_options.fetch(:association_name, singular_resource_name).to_s
      end # method association_name
      alias_method :parent_name, :association_name

      # The foreign key of the association from the root resource.
      #
      # @return [Symbol] The foreign key.
      def foreign_key
        @resource_options.fetch :foreign_key,
          :"#{tools.string.singularize association_name}_id"
      end # method foreign_keys

      # @see #namespaces
      #
      # @return [Array<Resource>] The parent resource definitions.
      def parent_resources
        namespaces.
          select { |hsh| hsh[:type] == :resource }.
          map { |hsh| hsh[:resource] }
      end # method parent_resources
    end # module
  end # class
end # module
