# spec/support/mocks/operation.rb

require 'bronze/operations/null_operation'

module Spec
  class Operation < Bronze::Operations::NullOperation
    def initialize resources: []
      @resources = resources
    end # constructor

    attr_reader :resources

    def fail! errors: nil, failure_message: nil
      unless errors || failure_message
        failure_message = 'operations.errors.generic_message'
      end # unless

      @errors          = errors
      @failure_message = failure_message

      self
    end # fail!

    def resource
      @resources.first
    end # method resource
  end # class
end # module
