# lib/bronze/rails/resources/resource.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource_builder'

module Bronze::Rails::Resources
  # Object representing a Rails resource. Provides methods to query properties
  # such as resourceful routes and template paths.
  class Resource # rubocop:disable Metrics/ClassLength
    # @param resource_class [Class] The base class representing instances of
    #   the resource.
    # @param resource_options [Hash] Additional options for the resource.
    def initialize resource_class, resource_options = {}, &block
      @resource_class   = resource_class
      @resource_options = tools.hash.convert_keys_to_symbols(resource_options)
      @namespaces       = []

      return unless block

      builder = Bronze::Rails::Resources::ResourceBuilder.new(self)
      builder.instance_exec(&block) if block
    end # constructor

    # @return [Array<Hash>] The parent resources and/or namespaces, from
    #   outermost to innermost. Each hash should have a :name value, a :type
    #   value with a value of either :namespace or :resource, and optionally a
    #   :resource value with a resource definition for the parent resource.
    attr_reader :namespaces

    # @return [Class] The base class representing instances of the resource.
    attr_reader :resource_class

    # @return [Hash] Additional options for the resource.
    attr_reader :resource_options

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
    # @see #resource_key
    def default_resource_key
      default_resource_name.intern
    end # method default_resource_key
    alias_method :default_plural_resource_key, :default_resource_key

    # @return [String] The default short name of the resource as a plural,
    #   underscore-separated string. The default name is based on the name of
    #   the resource class.
    #
    # @see #resource_name
    def default_resource_name
      @default_resource_name ||=
        tools.string.chain(
          @resource_class.name.split('::').last,
          :underscore,
          :pluralize
        ) # end chain
    end # method default_resource_name
    alias_method :default_plural_resource_name, :default_resource_name

    # @return [Symbol] The default short name of the resource as a singular,
    #   underscore-separated symbol. The default name is based on the name of
    #   the resource class.
    #
    # @see #default_resource_key
    def default_singular_resource_key
      default_singular_resource_name.intern
    end # method default_resource_key

    # @return [String] The default short name of the resource as a singular,
    #   underscore-separated string. The default name is based on the name of
    #   the resource class.
    #
    # @see #default_resource_name
    def default_singular_resource_name
      @default_singular_resource_name ||=
        tools.string.chain(
          @resource_class.name.split('::').last,
          :underscore,
          :singularize
        ) # end chain
    end # method default_resource_name

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

    # The primary key of the resource.
    #
    # @return [Symbol] The primary key.
    def primary_key
      @resource_options.fetch :primary_key, :"#{singular_resource_name}_id"
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

    # @return [Symbol] The short name of the resource as a plural,
    #   underscore-separated symbol.
    def resource_key
      resource_name.intern
    end # method resource_key
    alias_method :plural_resource_key, :resource_key

    # @return [String] The short name of the resource as a plural,
    #   underscore-separated string.
    def resource_name
      @resource_name ||=
        tools.string.chain(
          @resource_options.fetch(:resource_name) do
            resource_class.name.split('::').last
          end, # end fetch
          :underscore,
          :pluralize
        ) # end chain
    end # method resource_name
    alias_method :plural_resource_name, :resource_name

    # @return [Boolean] True if the name of the resource has been customized
    #   via a configuration option, otherwise false.
    def resource_name_changed?
      plural_resource_name != default_plural_resource_name ||
        singular_resource_name != default_singular_resource_name
    end # method resource_name_changed?

    # @return [String] The plural key to use when serializing a collection of
    #   the resource, such as in a JSON envelope or an error key.
    def serialization_key
      @serialization_key ||=
        if @resource_options.key?(:serialization_key)
          tools.string.chain(
            @resource_options.fetch(:serialization_key),
            :underscore,
            :pluralize
          ).intern
        else
          resource_key
        end # if
    end # method serialization_key
    alias_method :plural_serialization_key, :serialization_key

    # @return [Boolean] True if the serialization key of the resource has been
    #   customized via a configuration option, otherwise false.
    def serialization_key_changed?
      plural_serialization_key != default_plural_resource_key ||
        singular_serialization_key != default_singular_resource_key
    end # method serialization_key_changed?

    # @return [String] The short name of the resource as a singular,
    #   underscore-separated string.
    def singular_resource_key
      singular_resource_name.intern
    end # method singular_resource_name

    # @return [String] The short name of the resource as a singular,
    #   underscore-separated string.
    def singular_resource_name
      @singular_resource_name ||=
        if @resource_options.key?(:singular_resource_name)
          tools.string.underscore(
            @resource_options.fetch(:singular_resource_name)
          ) # end underscore
        else
          tools.string.singularize(plural_resource_name)
        end # if-else
    end # method singular_resource_name

    # @return [String] The singular key to use when serializing an instance of
    #   the resource, such as in a JSON envelope or an error key.
    def singular_serialization_key
      @singular_serialization_key ||=
        if @resource_options.key?(:singular_serialization_key)
          tools.string.underscore(
            @resource_options.fetch(:singular_serialization_key)
          ).intern
        elsif @resource_options.key?(:serialization_key)
          tools.string.singularize(plural_serialization_key).intern
        else
          singular_resource_key
        end # if-elsif-else
    end # method singular_serialization_key

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
