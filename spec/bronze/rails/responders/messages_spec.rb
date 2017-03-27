# spec/bronze/rails/responders/messages_spec.rb

require 'rails_helper'

require 'bronze/rails/responders/messages'
require 'bronze/rails/responders/responder'
require 'bronze/rails/responders/responder_examples'

require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Responders::Messages do
  include Spec::Examples::ResponderExamples

  let(:described_class) do
    Class.new(Bronze::Rails::Responders::Responder) do
      include Bronze::Rails::Responders::Messages
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

  describe '#build_message' do
    let(:resource_name) { resource_definition.resource_name }
    let(:action_name)   { 'defenestrate' }
    let(:status)        { nil }
    let(:expected_keys) do
      keys = []

      keys << "resources.#{resource_name}.#{action_name}.#{status}" if status
      keys << "resources.#{resource_name}.#{action_name}"
      keys << "resources.#{resource_name}.action.#{status}" if status
      keys << "resources.#{resource_name}.action"
      keys << "resources.#{action_name}.#{status}" if status
      keys << "resources.#{action_name}"
      keys << "resources.action.#{status}" if status
      keys << 'resources.action'
    end # let
    let(:expected) do
      options = {
        :resource => resource_name,
        :action   => action_name,
        :status   => status
      } # end options

      expected_keys.each.with_object({}) do |key, hsh|
        hsh[key] = options
      end # each
    end # let
    let(:message) do
      'This is a test of the emergency broadcast system. This is only a test.'
    end # let
    let(:i18n_service) { instance.send :i18n_service }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_message)

      expect(instance).to respond_to(:build_message, true).with(1..2).arguments
    end # it

    it 'should translate the message' do
      expect(i18n_service).
        to receive(:translate_with_fallbacks).
        with(expected, instance.send(:locale)).
        and_return(message)

      expect(instance.send :build_message, action_name, status).to be == message
    end # it

    describe 'with a status' do
      let(:status) { :success }

      it 'should translate the message' do
        expect(i18n_service).
          to receive(:translate_with_fallbacks).
          with(expected, instance.send(:locale)).
          and_return(message)

        expect(instance.send :build_message, action_name, status).
          to be == message
      end # it
    end # describe

    wrap_context 'when the locale is set' do
      it 'should translate the message' do
        expect(i18n_service).
          to receive(:translate_with_fallbacks).
          with(expected, locale).
          and_return(message)

        expect(instance.send :build_message, action_name, status).
          to be == message
      end # it
    end # wrap_context

    wrap_context 'when the resource has a parent resource' do
      let(:parent_name) do
        resource_definition.parent_resources.first.resource_name
      end # let
      let(:expected_keys) do
        keys = []

        if status
          keys << "resources.#{parent_name}.#{resource_name}.#{action_name}."\
                  "#{status}"
        end # if
        keys << "resources.#{parent_name}.#{resource_name}.#{action_name}"

        keys.concat super()
      end # let

      it 'should translate the message' do
        i18n_service = instance.send(:i18n_service)

        expect(i18n_service).
          to receive(:translate_with_fallbacks).
          with(expected, instance.send(:locale)).
          and_return(message)

        expect(instance.send :build_message, action_name, status).
          to be == message
      end # it

      describe 'with a status' do
        let(:status) { :success }

        it 'should translate the message' do
          i18n_service = instance.send(:i18n_service)

          expect(i18n_service).
            to receive(:translate_with_fallbacks).
            with(expected, instance.send(:locale)).
            and_return(message)

          expect(instance.send :build_message, action_name, status).
            to be == message
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      let(:parent_names) do
        resource_definition.parent_resources.map(&:resource_name).join('.')
      end # let
      let(:expected_keys) do
        keys = []

        if status
          keys << "resources.#{parent_names}.#{resource_name}.#{action_name}."\
                  "#{status}"
        end # if
        keys << "resources.#{parent_names}.#{resource_name}.#{action_name}"

        keys.concat super()
      end # let

      it 'should translate the message' do
        i18n_service = instance.send(:i18n_service)

        expect(i18n_service).
          to receive(:translate_with_fallbacks).
          with(expected, instance.send(:locale)).
          and_return(message)

        expect(instance.send :build_message, action_name, status).
          to be == message
      end # it

      describe 'with a status' do
        let(:status) { :success }

        it 'should translate the message' do
          i18n_service = instance.send(:i18n_service)

          expect(i18n_service).
            to receive(:translate_with_fallbacks).
            with(expected, instance.send(:locale)).
            and_return(message)

          expect(instance.send :build_message, action_name, status).
            to be == message
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
