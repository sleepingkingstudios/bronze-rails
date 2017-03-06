# lib/bronze/rails/responders/render_view_responder.rb

require 'bronze/rails/responders'

module Bronze::Rails::Responders
  # Responder for the omakase Rails behavior, e.g. an application or action that
  # renders a Rails template or redirects to another page within the
  # application.
  class RenderViewResponder
    # @param render_context [Object] The object to which render and redirect_to
    #   calls are delegated.
    def initialize render_context
      @render_context = render_context
    end # constructor

    # @return [Object] The object to which render and redirect_to calls are
    #   delegated.
    attr_reader :render_context

    # Either renders the requested template or redirects to the requested path.
    #
    # @param options [Hash] The parameters for the response.
    def call options
      if options.key?(:redirect_path)
        redirect_to(options)
      elsif options.key?(:template)
        render_template(options)
      end # if
    end # method call

    private

    def build_locals options
      locals = {}

      locals.update(options[:resources]) if options.key?(:resources)

      locals[:errors] = options[:errors] if options.key?(:errors)

      locals.update(options[:locals])    if options.key?(:locals)

      locals
    end # method build_locals

    def redirect_to options
      render_context.redirect_to(options.fetch :redirect_path)
    end # method redirect_to

    def render_template options
      status   = options.fetch(:http_status, :ok)
      template = options.fetch(:template)
      locals   = build_locals options

      render_context.render(
        :status   => status,
        :template => template,
        :locals   => locals
      ) # end render
    end # method render_template
  end # class
end # module
