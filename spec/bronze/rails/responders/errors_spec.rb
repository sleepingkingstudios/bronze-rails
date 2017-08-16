# spec/bronze/rails/responders/errors_spec.rb

require 'rails_helper'

require 'bronze/errors'

require 'bronze/rails/responders/errors'
require 'bronze/rails/responders/responder'
require 'bronze/rails/responders/responder_examples'

require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Responders::Errors do
  include Spec::Examples::ResponderExamples

  shared_context 'when the errors object has many errors' do
    let(:actual_errors) { generate_errors_for('books') }

    def build_errors ary
      ary.each.with_object(Bronze::Errors.new) do |err, errors|
        proxy = errors.dig(*err.fetch(:path))

        proxy.add(err.fetch(:type), err.fetch(:params, {}))
      end # each
    end # method build_errors

    def generate_errors_for name # rubocop:disable Metrics/MethodLength
      tools = SleepingKingStudios::Tools::Toolbelt.instance

      [
        {
          :path   => [],
          :type   => 'errors.unable_to_connect_to_server',
          :params => {}
        }, # end error
        {
          :path   => [:authorization],
          :type   => 'errors.forbidden_resource',
          :params => {}
        }, # end error
        {
          :path   => [tools.string.singularize(name).intern, :title],
          :type   => 'errors.must_be_present',
          :params => {}
        }, # end error
        {
          :path   => [tools.string.pluralize(name).intern, 0, :id],
          :type   => 'errors.must_be_present',
          :params => {}
        }, # end error
        {
          :path   => [tools.string.pluralize(name).intern, 0, :id],
          :type   => 'errors.must_be_greater_than',
          :params => { :value => 0 }
        } # end error
      ] # end errors
    end # method errors_for
  end # shared_context

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
        errors            = build_errors(actual_errors)

        expected_errors.each do |error|
          error_key = format_path error[:path]
          params    = error.fetch(:params, {}).merge(:locale => locale)
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

    let(:options)      { {} }
    let(:i18n_service) { instance.send :i18n_service }

    def format_path path
      path.map.with_index { |s, i| i == 0 ? s : "[#{s}]" }.join
    end # method format_path

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_error_messages)

      expect(instance).
        to respond_to(:build_error_messages, true).
        with(1..2).arguments
    end # it

    it 'should build the error messages' do
      expect(instance.send :build_error_messages, Bronze::Errors.new).
        to be == {}
    end # it

    wrap_context 'when the errors object has many errors' do
      let(:expected_errors) { actual_errors }

      include_examples 'should build the error messages'

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

      wrap_context 'when the locale is set' do
        include_examples 'should build the error messages'
      end # wrap_context

      context 'when the resource has a custom serialization key' do
        let(:resource_options) { super().merge :resource_name => 'tomes' }
        let(:expected_errors)  { generate_errors_for('tomes') }

        include_examples 'should build the error messages'
      end # context
    end # context
  end # describe
end # describe
