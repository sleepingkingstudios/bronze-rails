# lib/bronze/rails/resources/resource.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  # Object representing a Rails resource. Provides methods to query properties
  # such as resourceful routes and template paths.
  class Resource
    # @param resource_class [Class] The base class representing instances of the
    #   resource.
    # @param resource_options [Hash] Additional options for the resource.
    def initialize resource_class, resource_options = {}
      @resource_class   = resource_class
      @resource_options = resource_options
    end # constructor

    # @return [Class] The base class representing instances of the resource.
    attr_reader :resource_class

    # @return [Hash] Additional options for the resource.
    attr_reader :resource_options

    # The collection or table name used to persist the resource.
    #
    # @return [String] The collection name.
    def collection_name
      @collection_name ||= tools.string.pluralize(qualified_resource_name)
    end # method collection_name

    # @see #plural_resource_name
    #
    # @return [Symbol] The plural resource name.
    def plural_resource_key
      plural_resource_name.intern
    end # method plural_resource_key

    # The short plural name of the resource in underscore-separated form.
    #
    # @return [String] The plural resource name.
    def plural_resource_name
      @plural_resource_name ||= tools.string.pluralize(resource_name)
    end # method plural_resource_name

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

    # @see #resource_name
    #
    # @return [Symbol] The resource name.
    def resource_key
      resource_name.intern
    end # method resource_key

    # The short name of the resource in underscore-separated form.
    #
    # @return [String] The resource name.
    def resource_name
      @resource_name ||=
        tools.string.underscore(@resource_class.name.split('::').last)
    end # method resource_name

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
