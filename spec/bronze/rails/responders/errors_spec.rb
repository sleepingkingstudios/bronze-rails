# spec/bronze/rails/responders/errors_spec.rb

require 'rails_helper'

require 'bronze/errors'

require 'bronze/rails/responders/errors'
require 'bronze/rails/responders/responder'
require 'bronze/rails/responders/responder_examples'

require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Responders::Errors do
  include Spec::Examples::ResponderExamples

  let(:described_class) do
    Class.new(Bronze::Rails::Responders::Responder) do
      include Bronze::Rails::Responders::Errors
    end # class
  end # let
  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_definition) do
    Bronze::Rails::Resources::Resource.new resource_class, resource_options
  end # let
  let(:locale)           { nil }
  let(:instance_options) { { :locale => locale } }
  let(:instance) do
    described_class.new resource_definition, instance_options
  end # let

  describe '#build_error_messages' do
    shared_examples 'should build the error messages' do
      it 'should build the error messages' do
        expected_messages = {}

        errors.each do |error|
          error_key = format_path error[:path]
          params    = error[:params].merge(:locale => locale)
          message   =
            "translated, type: #{error[:type]}, params: "\
            "#{error[:params].inspect}"

          expect(i18n_service).
            to receive(:translate).
            with(error[:type], params).
            and_return(message)

          (expected_messages[error_key] ||= []) << message
        end # each

        expect(instance.send :build_error_messages, errors, options).
          to be == expected_messages
      end # it
    end # shared_examples

    let(:errors)       { Bronze::Errors.new }
    let(:options)      { {} }
    let(:i18n_service) { instance.send :i18n_service }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_error_messages)

      expect(instance).
        to respond_to(:build_error_messages, true).
        with(1..2).arguments
    end # it

    it 'should build the error messages' do
      expect(instance.send :build_error_messages, errors).to be == {}
    end # it

    context 'when the errors object has many errors' do
      let(:expected_errors) do
        {
          [] => {
            :unable_to_connect_to_server => {}
          }, # end root errors
          [:articles, 0, :id] => {
            :must_be_present      => {},
            :must_be_greater_than => { :value => 0 }
          } # end articles 0 id errors
        } # end expected_errors
      end # let

      before(:example) do
        expected_errors.each do |path, ary|
          proxy = errors.dig(*path)

          ary.each do |error_type, error_params|
            proxy.add error_type, **error_params
          end # each
        end # each
      end # before example

      def format_path path
        path.map.with_index { |s, i| i == 0 ? s : "[#{s}]" }.join
      end # method format_path

      include_examples 'should build the error messages'

      wrap_context 'when the locale is set' do
        include_examples 'should build the error messages'
      end # wrap_context

      describe 'with :format => :dot_separated' do
        let(:options) { super().merge :format => :dot_separated }

        def format_path path
          path.map(&:to_s).join('.')
        end # method format_path

        include_examples 'should build the error messages'
      end # describe

      describe 'with :format => :square_brackets' do
        let(:options) { super().merge :format => :square_brackets }

        def format_path path
          path.map.with_index { |s, i| i == 0 ? s : "[#{s}]" }.join
        end # method format_path

        include_examples 'should build the error messages'
      end # describe
    end # context
  end # describe
end # describe
