# spec/support/mocks/controller.rb

require 'patina/collections/simple/repository'

module Spec
  class Controller
    def initialize action_name: nil, params: {}, repository: nil
      @action_name = action_name
      @params      = ActionController::Parameters.new(params)
      @repository  = repository
    end # constructor

    private

    attr_reader :action_name, :params

    def redirect_to; end

    def render; end

    def repository
      @repository ||= Patina::Collections::Simple::Repository.new
    end # method repository
  end # class
end # module
