# lib/bronze/rails/services/i18n_service.rb

require 'bronze/rails/services'

module Bronze::Rails::Services
  # Service object that wraps I18n with fallback functionality.
  class I18nService
    def self.instance
      @instance ||= new
    end # class method instance

    # @param default_locale [String] The default locale.
    def initialize default_locale = nil
      @default_locale = default_locale
    end # constructor

    # @return [String] The default locale, either passed in to the service
    #   instance or delegated to I18n.
    def default_locale
      @default_locale ||= I18n.default_locale
    end # method default_locale

    # Passes the key and interpolation variables to I18n.
    #
    # @param key [String, Symbol] The translation key.
    # @param opts [Hash] The interpolation variables.
    #
    # @param [String] The translated string.
    def translate key, opts = {}
      opts = { :locale => default_locale }.update(opts)

      I18n.translate(key, opts)
    end # method translate

    # Tries each key-options pair in sequence and returns the first translated
    # value that matches a translation in the present locale.
    #
    # @param opts [Hash] Ordered hash of translation options, with the key being
    #   the translation key and the value the interpolation variables for that
    #   key.
    #
    # @param [String] The translated string.
    def translate_with_fallbacks opts, locale = nil
      locale ||= default_locale

      opts.each.with_index do |(key, vars), index|
        next unless I18n.exists?(key, locale) || index == opts.count - 1

        return I18n.translate(key, vars)
      end # each
    end # method translate_with_fallbacks
  end # class
end # module
