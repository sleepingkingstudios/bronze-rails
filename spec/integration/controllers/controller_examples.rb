# spec/integration/controllers/controller_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec
  module Examples
    module Integration; end
  end # module
end # module

module Spec::Examples::Integration
  module ControllerExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should respond with' do |status, *args|
      block = args.pop if args.last.is_a?(Proc)
      opts  = args.last.is_a?(Hash) ? args.pop : {}

      # :nocov:
      status_code =
        if status.is_a?(Symbol)
          Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch status
        else
          status
        end # if-else
      # :nocov:
      status_description =
        Rack::Utils::HTTP_STATUS_CODES.fetch status_code
      example_description =
        "should respond with #{status_code} #{status_description}"
      if opts.key?(:description)
        example_description << ' ' << opts[:description]
      end # if

      it example_description do
        allow(controller).to receive(:render).and_call_original

        perform_action

        expect(response.status).to be == status_code

        instance_exec(&block) if block.is_a?(Proc)
      end # it
    end # shared_examples

    shared_examples 'should render template' do |template, *args|
      block  = args.pop if args.last.is_a?(Proc)
      opts   = args.last.is_a?(Hash) ? args.pop : {}
      status = opts.fetch :status, :ok

      include_examples 'should respond with',
        status,
        { :description => "and render template #{template}" },
        lambda {
          expect(controller).to have_received(:render) { |options|
            expect(options[:template]).to be == template

            instance_exec(options, &block) if block.is_a?(Proc)
          } # end render options
        } # end lambda
    end # shared_examples
  end # module
end # module
