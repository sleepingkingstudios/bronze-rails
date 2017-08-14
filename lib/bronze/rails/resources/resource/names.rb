# lib/bronze/rails/resources/resource/names.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  class Resource
    # Functionality for resource names and variations for a Rails resource.
    module Names # rubocop:disable Metrics/ModuleLength
      # The collection or table name used to persist the resource.
      #
      # @return [String] The collection name.
      def collection_name
        @collection_name ||=
          if @resource_options.key?(:collection_name)
            @resource_options.fetch(:collection_name).to_s
          else
            tools.string.pluralize(qualified_resource_name)
          end # if-else
      end # method collection_name

      # The name of the controller for the resource in underscored format.
      #
      # @return [String] The controller name.
      def controller_name
        @controller_name ||=
          if @resource_options.key?(:controller_name)
            tools.string.underscore(@resource_options.fetch(:controller_name)).
              sub(/_controller\z/, '')
          else
            plural_resource_name
          end # if-else
      end # method controller_name

      # @return [Symbol] The default short name of the resource as a plural,
      #   underscore-separated symbol. The default name is based on the name of
      #   the resource class.
      #
      # @see #plural_resource_key
      def default_plural_resource_key
        default_plural_resource_name.intern
      end # method default_plural_resource_key

      # @return [String] The default short name of the resource as a plural,
      #   underscore-separated string. The default name is based on the name of
      #   the resource class.
      #
      # @see #plural_resource_name
      def default_plural_resource_name
        @default_plural_resource_name ||=
          tools.string.pluralize(default_resource_name)
      end # method default_plural_resource_name

      # @return [Symbol] The default short name of the resource as a singular,
      #   underscore-separated symbol. The default name is based on the name of
      #   the resource class.
      #
      # @see #resource_key
      def default_resource_key
        default_resource_name.intern
      end # method default_resource_key

      # @return [String] The default short name of the resource as a singular,
      #   underscore-separated string. The default name is based on the name of
      #   the resource class.
      #
      # @see #resource_name
      def default_resource_name
        @default_resource_name ||=
          tools.string.chain(
            @resource_class.name.split('::').last,
            :underscore,
            :singularize
          ) # end chain
      end # method default_resource_name

      # @return [String] The short name of the resource as a plural,
      #   underscore-separated string.
      #
      # @see #default_resource_name
      def plural_resource_key
        plural_resource_name.intern
      end # method plural_resource_key

      # @return [String] The short name of the resource as a plural,
      #   underscore-separated string.
      #
      # @see #default_resource_name
      def plural_resource_name
        @plural_resource_name ||=
          if @resource_options.key?(:plural_resource_name)
            tools.string.underscore(
              @resource_options.fetch(:plural_resource_name)
            ) # end underscore
          else
            tools.string.pluralize(singular_resource_name)
          end # if-else
      end # method plural_resource_name

      # @return [String] The plural key to use when serializing a collection of
      #   the resource, such as in a JSON envelope or an error key.
      def plural_serialization_key
        @plural_serialization_key ||=
          if @resource_options.key?(:plural_serialization_key)
            tools.string.underscore(
              @resource_options.fetch(:plural_serialization_key)
            ).intern
          elsif @resource_options.key?(:serialization_key)
            tools.string.pluralize(singular_serialization_key).intern
          else
            plural_resource_key
          end # if-elsif-else
      end # method plural_serialization_key

      # The primary key of the resource.
      #
      # @return [Symbol] The primary key.
      def primary_key
        @resource_options.fetch :primary_key, :"#{resource_name}_id"
      end # method primary_key

      # The full name of the resource in a standardized, hyphen- and
      # underscore-separated form.
      #
      # @return [String] The qualified name.
      def qualified_resource_name
        @qualified_resource_name ||=
          begin
            @resource_class.name.split('::').map do |str|
              tools.string.underscore(str)
            end.join('-')
          end # name
      end # method qualified_resource_name

      # @return [Symbol] The short name of the resource as a singular,
      #   underscore-separated symbol.
      def resource_key
        resource_name.intern
      end # method resource_key
      alias_method :singular_resource_key, :resource_key

      # @return [String] The short name of the resource as a singular,
      #   underscore-separated string.
      def resource_name
        @resource_name ||=
          tools.string.chain(
            @resource_options.fetch(:resource_name) do
              resource_class.name.split('::').last
            end, # end fetch
            :underscore,
            :singularize
          ) # end chain
      end # method resource_name
      alias_method :singular_resource_name, :resource_name

      # @return [Boolean] True if the name of the resource has been customized
      #   via a configuration option, otherwise false.
      def resource_name_changed?
        resource_name != default_resource_name ||
          plural_resource_name != default_plural_resource_name
      end # method resource_name_changed?

      # @return [String] The singular key to use when serializing an instance of
      #   the resource, such as in a JSON envelope or an error key.
      def serialization_key
        @serialization_key ||=
          if @resource_options.key?(:serialization_key)
            tools.string.chain(
              @resource_options.fetch(:serialization_key),
              :underscore,
              :singularize
            ).intern
          else
            resource_key
          end # if
      end # method serialization_key
      alias_method :singular_serialization_key, :serialization_key

      # @return [Boolean] True if the serialization key of the resource has been
      #   customized via a configuration option, otherwise false.
      def serialization_key_changed?
        serialization_key != default_resource_key ||
          plural_serialization_key != default_plural_resource_key
      end # method serialization_key_changed?
    end # module
  end # class
end # module
