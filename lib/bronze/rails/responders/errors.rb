# lib/bronze/rails/responders/errors.rb

require 'bronze/rails/responders'
require 'bronze/rails/services/i18n_service'

module Bronze::Rails::Responders
  # Mixin for building internationalized error messages.
  module Errors
    private

    def build_error_messages errors, options = {}
      key_format     = options.fetch(:format, :square_brackets)
      error_messages = {}

      errors.each do |error|
        error_key = send(:"format_key_as_#{key_format}", error[:path])
        params    = error[:params].merge :locale => locale
        message   = i18n_service.translate(error[:type], params)
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
  end # module
end # module
