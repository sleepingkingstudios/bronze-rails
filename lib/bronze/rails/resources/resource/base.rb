# lib/bronze/rails/resources/resource/base.rb

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource/builder'

module Bronze::Rails::Resources
  class Resource
    # Core functionality for an object representing a Rails resource.
    module Base
      # @param resource_class [Class] The base class representing instances of
      #   the resource.
      # @param resource_options [Hash] Additional options for the resource.
      def initialize resource_class, resource_options = {}, &block
        @resource_class   = resource_class
        @resource_options = tools.hash.convert_keys_to_symbols(resource_options)
        @namespaces       = []

        return unless block

        builder = Bronze::Rails::Resources::Resource::Builder.new(self)
        builder.instance_exec(&block) if block
      end # constructor

      # @return [Array<Hash>] The parent resources and/or namespaces, from
      #   outermost to innermost. Each hash should have a :name value, a
      #   :type value with a value of either :namespace or :resource, and
      #   optionally a :resource value with a resource definition for the parent
      #   resource.
      attr_reader :namespaces

      # @reurn [Class] The base class representing instances of the resource.
      attr_reader :resource_class

      # @return [Hash] Additional options for the resource.
      attr_reader :resource_options

      private

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end # method tools
    end # module
  end # class
end # module
