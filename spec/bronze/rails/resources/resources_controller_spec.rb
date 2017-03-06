# spec/bronze/rails/resources/resources_controller_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'
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
  let(:instance) { described_class.new }

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
end # describe
