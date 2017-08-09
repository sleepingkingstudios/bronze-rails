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

      # Declares that the resource is nested within a namespace. Each namespace
      # and parent resource must be declared in order from the outside in.
      #
      # @param name [String, Symbol] The name of the namespace.
      def namespace name
        declare_namespace(name.intern)
      end # method namespace

      # Declares that the resource has a parent resource with the specified name
      # and options. In addition, the parent resource will be defined with the
      # existing namespace(s) and/or parent resources already declared for the
      # current resource.
      #
      # @param parent_class [Class] The base class representing instances of
      #   the parent resource.
      # @param parent_options [Hash] Configuration options for the resource.
      def parent_resource parent_class, parent_options = {}
        resource =
          Bronze::Rails::Resources::Resource.new(parent_class, parent_options)

        namespaces.each do |hsh|
          if hsh[:type] == :namespace
            resource.declare_namespace(hsh.fetch :name)
          else
            resource.declare_parent_resource(hsh.fetch :resource)
          end # if-else
        end # each

        declare_parent_resource(resource)
      end # method parent_resource

      # @see #namespaces
      #
      # @return [Array<Resource>] The parent resource definitions.
      def parent_resources
        namespaces.
          select { |hsh| hsh[:type] == :resource }.
          map { |hsh| hsh[:resource] }
      end # method parent_resources

      protected

      def declare_namespace name
        @namespaces << { :name => name, :type => :namespace }
      end # method declare_namespace

      def declare_parent_resource resource
        @namespaces <<
          {
            :name     => resource.plural_resource_name,
            :type     => :resource,
            :resource => resource
          } # end namespace
      end # method declare_parent_resource
    end # module
  end # class
end # module
