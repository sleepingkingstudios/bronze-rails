# lib/bronze/rails/resources/resource/base.rb

require 'bronze/rails/resources'

module Bronze::Rails::Resources
  class Resource
    # Core functionality for an object representing a Rails resource.
    module Base
      # @param resource_class [Class] The base class representing instances of
      #   the resource.
      # @param resource_options [Hash] Additional options for the resource.
      def initialize resource_class, resource_options = {}
        @resource_class   = resource_class
        @resource_options = resource_options
      end # constructor

      # @reurn [Class] The base class representing instances of the resource.
      attr_reader :resource_class

      # @return [Hash] Additional options for the resource.
      attr_reader :resource_options
    end # module
  end # class
end # module
