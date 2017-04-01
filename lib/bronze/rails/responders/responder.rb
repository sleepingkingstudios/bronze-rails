# lib/bronze/rails/responders/responder.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/responders'

module Bronze::Rails::Responders
  # Abstract responder class that provides common functionality.
  class Responder
    # @param resource_definition [Resource] The definition of the primary
    #   resource.
    # @param options [Hash] Additional options and context for the response.
    def initialize resource_definition, options = {}
      @resource_definition = resource_definition
      @options             = options
    end # constructor

    # @return [Resource] The definition of the primary resource.
    attr_reader :resource_definition

    # @return [String] The configured locale for i18n, or nil if no locale was
    #   configured.
    def locale
      @options[:locale]
    end # method locale

    private

    def ancestors
      resources = @options.fetch(:resources, {})

      @resource_definition.parent_resources.map do |ancestor|
        resources[ancestor.parent_key]
      end # map
    end # method ancestors

    def resource_path resource
      @resource_definition.resource_path(*ancestors, resource)
    end # method resource_path

    def resources_path
      @resource_definition.resources_path(*ancestors)
    end # method resources_path

    def tools
      # :nocov:
      SleepingKingStudios::Tools::Toolbelt.instance
      # :nocov:
    end # method tools
  end # class
end # module
