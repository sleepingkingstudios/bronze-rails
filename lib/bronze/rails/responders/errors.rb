# lib/bronze/rails/responders/errors.rb

require 'bronze/rails/responders'
require 'bronze/rails/services/i18n_service'

module Bronze::Rails::Responders
  # Mixin for building internationalized error messages.
  module Errors
    private

    def build_error_message error
      params = error[:params].merge :locale => locale

      i18n_service.translate(error[:type], params)
    end # method build_error_message

    def build_error_messages errors, options = {}
      key_format     = options.fetch(:format, :square_brackets)
      error_messages = {}

      errors.each do |error|
        path      = map_error_path(*error[:path])
        error_key = send(:"format_key_as_#{key_format}", path)
        message   = build_error_message(error)
        scoped    = error_messages[error_key] ||= []

        scoped << message unless scoped.include?(message)
      end # each

      error_messages
    end # method build_error_messages

    def format_key_as_dot_separated path
      path.map(&:to_s).join('.')
    end # method format_key_as_dot_separated

    def format_key_as_square_brackets path
      path.map.with_index { |s, i| i.zero? ? s : "[#{s}]" }.join
    end # method format_key_as_square_brackets

    def i18n_service
      Bronze::Rails::Services::I18nService.instance
    end # method i18n_service

    def map_error_path first = nil, *rest
      return [] if first.nil?

      unless resource_definition.serialization_key_changed?
        return [first, *rest]
      end # unless

      [map_error_prefix(first), *rest]
    end # method map_error_path

    def map_error_prefix prefix
      if prefix == resource_definition.default_plural_resource_key
        resource_definition.plural_serialization_key
      elsif prefix == resource_definition.default_singular_resource_key
        resource_definition.singular_serialization_key
      else
        prefix
      end # if-elsif
    end # method map_error_prefix
  end # module
end # module
