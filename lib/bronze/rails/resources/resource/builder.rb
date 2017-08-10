# lib/bronze/rails/resources/resource/builder.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  class Resource
    # Builder class to update a resource with namespace and parent resource
    # configuration on resource initialization.
    class Builder
      # @param resource [Bronze::Rails::Resources::Resource] The resource to
      #   update.
      def initialize resource
        @resource = resource
      end # constructor

      # @return [Bronze::Rails::Resources::Resource] The resource to update.
      attr_reader :resource

      # Declares that the resource is nested within a namespace. Each namespace
      # and parent resource must be declared in order from the outside in.
      #
      # @param name [String, Symbol] The name of the namespace.
      def namespace name
        declare_namespace(resource, name.intern)
      end # method namespace

      # @overload parent_resource parent_class, parent_options = {}
      #   Declares that the resource has a parent resource with the specified
      #   class and options. In addition, the parent resource will be defined
      #   with the existing namespace(s) and/or parent resources already
      #   declared for the current resource.
      #
      #   @param parent_class [Class] The base class representing instances of
      #     the parent resource.
      #   @param parent_options [Hash] Configuration options for the resource.
      # @overload parent_resource parent_name, parent_options = {}
      #   Declares that the resource has a parent resource with the specified
      #   name and options. In addition, the parent resource will be defined
      #   with the existing namespace(s) and/or parent resources already
      #   declared for the current resource.
      #
      #   @param parent_name [String, Symbol] The name of the parent resource.
      #   @param parent_options [Hash] Configuration options for the resource.
      def parent_resource class_or_name, parent_options = {}
        parent = build_parent(class_or_name, parent_options)

        resource.namespaces.each do |hsh|
          if hsh[:type] == :namespace
            declare_namespace(parent, hsh.fetch(:name))
          else
            declare_parent_resource(parent, hsh.fetch(:resource))
          end # if-else
        end # each

        declare_parent_resource(resource, parent)
      end # method parent_resource

      private

      def build_parent class_or_name, options
        if class_or_name.is_a?(Class)
          Bronze::Rails::Resources::Resource.new(class_or_name, options)
        elsif options.key?(:class)
          options      = options.dup
          parent_class = options.delete(:class)

          build_parent_by_name_and_class(class_or_name, parent_class, options)
        else
          build_parent_by_name(class_or_name, options)
        end # if-else
      end # method build_parent

      def build_parent_by_name parent_name, options
        parent_class = find_class_by_name(parent_name)

        build_parent_by_name_and_class(parent_name, parent_class, options)
      end # method build_parent_by_name

      def build_parent_by_name_and_class parent_name, parent_class, options
        options = options.merge(:resource_name => parent_name)

        Bronze::Rails::Resources::Resource.new(parent_class, options)
      end # method build_parent_by_name

      def declare_namespace resource, name
        resource.namespaces << { :name => name, :type => :namespace }
      end # method declare_namespace

      def declare_parent_resource resource, parent
        resource.namespaces <<
          {
            :name     => parent.plural_resource_key,
            :type     => :resource,
            :resource => parent
          } # end namespace
      end # method declare_parent_resource

      def find_class_by_name class_name
        class_or_name = tools.string.chain(class_name, :singularize, :camelize)

        Object.const_get(class_or_name)
      end # method find_class_by_name

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end # method tools
    end # class
  end # class
end # module
