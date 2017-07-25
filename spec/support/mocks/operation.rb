# spec/support/mocks/operation.rb

require 'bronze/operations/null_operation'

module Spec
  class Operation < Bronze::Operations::NullOperation
    def initialize resources: []
      @resources = resources
    end # constructor

    attr_reader :resources

    # :nocov:
    def fail! errors: nil
      @errors = errors ||
                Bronze::Errors.new.add('operations.errors.generic_message')

      self
    end # fail!
    # :nocov:
  end # class
end # module
