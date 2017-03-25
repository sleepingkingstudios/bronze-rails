# lib/bronze/rails/responders/messages.rb

require 'bronze/rails/responders'
require 'bronze/rails/services/i18n_service'

module Bronze::Rails::Responders
  # Mixin for building internationalized messages based on action and status.
  module Messages
    private

    def build_message action_name, status = nil
      message_options = {
        :resource => resource_definition.resource_name,
        :action   => action_name,
        :status   => status
      } # end options

      translations =
        message_keys(action_name, status).each.with_object({}) do |key, hsh|
          hsh[key] = message_options
        end # each

      i18n_service.translate_with_fallbacks(translations, locale)
    end # method build_message

    def i18n_service
      Bronze::Rails::Services::I18nService.instance
    end # method i18n_service

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def message_keys action_name, status
      parent_resources = resource_definition.parent_resources
      resource_name    = resource_definition.resource_name
      keys             = []

      unless parent_resources.empty?
        parent_names = parent_resources.map(&:resource_name).join('.')

        if status
          keys << "resources.#{parent_names}.#{resource_name}.#{action_name}."\
                  "#{status}"
        end # if
        keys << "resources.#{parent_names}.#{resource_name}.#{action_name}"
      end # unless

      keys << "resources.#{resource_name}.#{action_name}.#{status}" if status
      keys << "resources.#{resource_name}.#{action_name}"
      keys << "resources.#{resource_name}.action.#{status}" if status
      keys << "resources.#{resource_name}.action"
      keys << "resources.#{action_name}.#{status}" if status
      keys << "resources.#{action_name}"
      keys << "resources.action.#{status}" if status
      keys << 'resources.action'
    end # method message_keys
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
  end # module
end # module
