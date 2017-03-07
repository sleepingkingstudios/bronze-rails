# spec/bronze/rails/resources/resources_controller_spec.rb

require 'rails_helper'

require 'bronze/operations/null_operation'

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'support/mocks/controller'

RSpec.describe Bronze::Rails::Resources::ResourcesController do
  shared_context 'when the resource is defined' do
    before(:example) do
      described_class.resource resource_class, resource_options
    end # before example
  end # shared_context

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:described_class) do
    Class.new(Spec::Controller) do
      include Bronze::Rails::Resources::ResourcesController
    end # described_class
  end # let
  let(:action_name) { nil }
  let(:params)      { {} }
  let(:instance) do
    described_class.new :action_name => action_name, :params => params
  end # let

  describe '::resource' do
    it { expect(described_class).to respond_to(:resource).with(1..2).arguments }
  end # describe

  describe '::resource_definition' do
    it 'should define the reader' do
      expect(described_class).
        to have_reader(:resource_definition).
        with_value(nil)
    end # it

    wrap_context 'when the resource is defined' do
      it 'should return the resource definition' do
        definition = described_class.resource_definition

        expect(definition).to be_a Bronze::Rails::Resources::Resource
        expect(definition.resource_class).to be resource_class
        expect(definition.resource_options).to be == resource_options
      end # it
    end # wrap_context
  end # describe

  ##############################################################################
  ###                                 Actions                                ###
  ##############################################################################

  describe '#index' do
    include_context 'when the resource is defined'

    let(:operation) { Bronze::Operations::NullOperation.new }
    let(:response)  { double('response') }

    it { expect(instance).to respond_to(:index).with(0).arguments }

    it 'should delegate to the operation' do
      expect(instance).
        to receive(:find_matching_resources).
        with(resource_class, instance.send(:filter_params)).
        and_return(operation)

      expect(instance).
        to receive(:build_response).
        with(operation).
        and_return(response)

      expect(instance.send :responder).
        to receive(:call).
        with(response)

      instance.index
    end # it
  end # describe

  ##############################################################################
  ###                               Operations                               ###
  ##############################################################################

  describe '#find_matching_resources' do
    it 'should define the method' do
      expect(instance).
        to respond_to(:find_matching_resources, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :find_matching_resources, resource_class, {}

      expect(operation).
        to be_a Patina::Operations::Entities::FindMatchingOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  ##############################################################################
  ###                                 Helpers                                ###
  ##############################################################################

  describe '#build_response' do
    let(:action_name) { :index }
    let(:operation)   { double('operation') }
    let(:builder)     { instance.send :response_builder }
    let(:response)    { double('response') }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_response)

      expect(instance).to respond_to(:build_response, true).with(1).argument
    end # it

    it 'should call the response builder' do
      allow(instance).to receive(:response_builder).and_return(builder)

      expect(builder).
        to receive(:build_response).
        with(operation, :action => action_name).
        and_return(response)

      expect(instance.send :build_response, operation).to be response
    end # it
  end # describe

  describe '#filter_params' do
    let(:expected) { { 'matching' => {} } }

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:filter_params)

      expect(instance).to respond_to(:filter_params, true).with(0).arguments
    end # it

    it { expect(instance.send :filter_params).to be == expected }

    describe 'with matching :title => value' do
      let(:params) do
        super().merge :matching => { :title => 'A Princess of Mars' }
      end # let
      let(:expected) { { 'matching' => { 'title' => 'A Princess of Mars' } } }

      it { expect(instance.send :filter_params).to be == expected }
    end # describe
  end # describe

  describe '#resource_class' do
    include_examples 'should have reader', :resource_class, nil

    wrap_context 'when the resource is defined' do
      it 'should return the resource definition' do
        expect(instance.resource_class).to be resource_class
      end # it
    end # wrap_context
  end # describe

  describe '#resource_definition' do
    include_examples 'should have reader', :resource_definition, nil

    wrap_context 'when the resource is defined' do
      it 'should return the resource definition' do
        definition = instance.resource_definition

        expect(definition).to be_a Bronze::Rails::Resources::Resource
        expect(definition.resource_class).to be resource_class
        expect(definition.resource_options).to be == resource_options
      end # it
    end # wrap_context
  end # describe

  describe '#responder' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:responder)

      expect(instance).to respond_to(:responder, true).with(0).arguments
    end # it

    it 'should be a responder instance' do
      responder = instance.send :responder

      expect(responder).to be_a Bronze::Rails::Responders::RenderViewResponder
      expect(responder.render_context).to be instance
    end # it
  end # describe

  describe '#response_builder' do
    include_context 'when the resource is defined'

    it 'should define the private method' do
      expect(instance).not_to respond_to(:response_builder)

      expect(instance).
        to respond_to(:response_builder, true).
        with(0..1).arguments
    end # it

    it 'should be a response builder instance' do
      builder = instance.send :response_builder

      expect(builder).
        to be_a Bronze::Rails::Resources::ResourcefulResponseBuilder
      expect(builder.resource_definition).
        to be described_class.resource_definition
    end # it

    describe 'with a resource definition' do
      let(:other_definition) do
        Bronze::Rails::Resources::Resource.new Spec::Chapter, {}
      end # let

      it 'should be a response builder instance' do
        builder = instance.send :response_builder, other_definition

        expect(builder).
          to be_a Bronze::Rails::Resources::ResourcefulResponseBuilder
        expect(builder.resource_definition).to be other_definition
      end # it
    end # describe
  end # describe
end # describe
