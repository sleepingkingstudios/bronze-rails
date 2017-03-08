# spec/support/mocks/controller.rb

require 'patina/collections/simple/repository'

module Spec
  class Controller
    class << self
      def before_action method_name, options = {}
        add_callback :before, method_name, options
      end # class method before_action

      def callbacks
        @callbacks ||= { :before => [], :after => [] }
      end # method callbacks

      private

      def add_callback hook, method_name, options
        callbacks[hook] << { :method_name => method_name, :options => options }
      end # method add_callback
    end # eigenclass

    def initialize action_name: nil, params: {}, repository: nil
      @action_name = action_name
      @params      = ActionController::Parameters.new(params)
      @repository  = repository
    end # constructor

    def redirect_to _; end

    def render; end

    # rubocop:disable Metrics/AbcSize
    def run_callbacks hook
      # :nocov:
      self.class.callbacks[hook].each do |callback|
        next if callback[:options].key?(:except) &&
                callback[:options][:except].include?(action_name)

        next if callback[:options].key?(:only) &&
                !callback[:options][:only].include?(action_name)

        send callback[:method_name]
      end # each
      # :nocov:
    end # method run_callbacks
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :action_name, :params

    def repository
      @repository ||= Patina::Collections::Simple::Repository.new
    end # method repository
  end # class
end # module
