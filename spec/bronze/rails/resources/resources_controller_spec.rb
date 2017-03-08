# spec/bronze/rails/resources/resources_controller_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'support/mocks/controller'
require 'support/mocks/operation'

RSpec.describe Bronze::Rails::Resources::ResourcesController do
  shared_context 'when the resource is defined' do
    before(:example) do
      described_class.resource resource_class, resource_options
    end # before example
  end # shared_context

  shared_context 'when a subset of attributes are permitted' do
    before(:example) do
      described_class.send :define_method,
        :permitted_attributes,
        ->() { %w(title series) }
    end # before example
  end # shared_context

  shared_context 'when all attributes are permitted' do
    before(:example) do
      described_class.send :define_method,
        :permitted_attributes,
        ->() { resource_class.attributes.keys }
    end # before example
  end # shared_context

  shared_examples 'should delegate to the operation' \
  do |action_name, operation_name = nil|
    operation_name ||= :"#{action_name}_resource"

    let(:operation) { Spec::Operation.new.execute }
    let(:response)  { double('response') }

    it "should delegate to the ##{operation_name} operation" do
      expect(instance).
        to receive(operation_name).
        with(no_args).
        and_return(operation)

      expect(instance).
        to receive(:build_response).
        with(operation).
        and_return(response)

      expect(instance.send :responder).
        to receive(:call).
        with(response)

      instance.send(action_name)
    end # it
  end # shared_examples

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

  describe '#create' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:create).with(0).arguments }

    include_examples 'should delegate to the operation', :create
  end # describe

  describe '#edit' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:edit).with(0).arguments }

    include_examples 'should delegate to the operation', :edit
  end # describe

  describe '#index' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:index).with(0).arguments }

    include_examples 'should delegate to the operation',
      :index,
      :index_resources
  end # describe

  describe '#new' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:new).with(0).arguments }

    include_examples 'should delegate to the operation', :new
  end # describe

  describe '#show' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:show).with(0).arguments }

    include_examples 'should delegate to the operation', :show
  end # describe

  ##############################################################################
  ###                                 Actions                                ###
  ##############################################################################

  describe '#create_resource' do
    include_context 'when the resource is defined'

    let(:resource)  { Spec::Book.new }
    let(:build_operation) do
      Spec::Operation.new(:resources => [resource]).execute
    end # let
    let(:validate_operation) do
      Spec::Operation.new(:resources => [resource]).execute
    end # let
    let(:insert_operation) do
      Spec::Operation.new(:resources => [resource]).execute
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:create_resource)

      expect(instance).
        to respond_to(:create_resource, true).
        with(0).arguments
    end # it

    it 'should build, validate and insert the resource' do
      expect(instance).
        to receive(:build_resource).
        with(resource_class, instance.send(:resource_params)).
        and_return(build_operation)

      expect(instance).
        to receive(:validate_resource).
        with(build_operation.resource).
        and_return(validate_operation)

      expect(instance).
        to receive(:insert_resource).
        with(validate_operation.resource).
        and_return(insert_operation)

      expect(instance.send :create_resource).to be insert_operation
    end # it
  end # describe

  describe '#edit_resource' do
    include_context 'when the resource is defined'

    let(:resource)  { Spec::Book.new }
    let(:operation) { Spec::Operation.new(:resources => [resource]).execute }
    let(:params)    { super().merge :id => resource.id }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:edit_resource)

      expect(instance).
        to respond_to(:edit_resource, true).
        with(0).arguments
    end # it

    it 'should require the resource' do
      expect(instance).
        to receive(:find_resource).
        with(resource_class, params[:id]).
        and_return(operation)

      expect(instance.send :edit_resource).to be operation
    end # it
  end # describe

  describe '#index_resources' do
    include_context 'when the resource is defined'

    let(:operation) { Bronze::Operations::NullOperation.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:index_resources)

      expect(instance).
        to respond_to(:index_resources, true).
        with(0).arguments
    end # it

    it 'should find the matching resources' do
      expect(instance).
        to receive(:find_matching_resources).
        with(resource_class, instance.send(:filter_params)).
        and_return(operation)

      expect(instance.send :index_resources).to be operation
    end # it
  end # describe

  describe '#new_resource' do
    include_context 'when the resource is defined'

    let(:operation) { Spec::Operation.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:new_resource)

      expect(instance).
        to respond_to(:new_resource, true).
        with(0).arguments
    end # it

    it 'should build the resource' do
      expect(instance).
        to receive(:build_resource).
        with(resource_class, instance.send(:resource_params)).
        and_return(operation)

      expect(instance.send :new_resource).to be operation
    end # it
  end # describe

  describe '#show_resource' do
    include_context 'when the resource is defined'

    let(:resource)  { Spec::Book.new }
    let(:operation) { Spec::Operation.new(:resources => [resource]).execute }
    let(:params)    { super().merge :id => resource.id }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:show_resource)

      expect(instance).
        to respond_to(:show_resource, true).
        with(0).arguments
    end # it

    it 'should require the resource' do
      expect(instance).
        to receive(:find_resource).
        with(resource_class, params[:id]).
        and_return(operation)

      expect(instance.send :show_resource).to be operation
    end # it
  end # describe

  ##############################################################################
  ###                               Operations                               ###
  ##############################################################################

  describe '#build_resource' do
    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_resource)

      expect(instance).
        to respond_to(:build_resource, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :build_resource, resource_class, {}

      expect(operation).
        to be_a Patina::Operations::Entities::BuildOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#find_matching_resources' do
    it 'should define the private method' do
      expect(instance).not_to respond_to(:find_matching_resources)

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

  describe '#find_resource' do
    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:find_resource)

      expect(instance).
        to respond_to(:find_resource, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :find_resource, resource_class, resource.id

      expect(operation).
        to be_a Patina::Operations::Entities::FindOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#insert_resource' do
    include_context 'when the resource is defined'

    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:insert_resource)

      expect(instance).
        to respond_to(:insert_resource, true).
        with(1).argument
    end # it

    it 'should return an operation' do
      operation = instance.send :insert_resource, resource

      expect(operation).
        to be_a Patina::Operations::Entities::InsertOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#validate_resource' do
    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:validate_resource)

      expect(instance).
        to respond_to(:validate_resource, true).
        with(1).argument
    end # it

    it 'should return an operation' do
      operation = instance.send :validate_resource, resource

      expect(operation).
        to be_a Patina::Operations::Entities::ValidateOneOperation
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

  describe '#permitted_attributes' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:permitted_attributes)

      expect(instance).
        to respond_to(:permitted_attributes, true).
        with(0).arguments
    end # it

    it { expect(instance.send :permitted_attributes).to be == [] }
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

  describe '#resource_params' do
    include_context 'when the resource is defined'

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:resource_params)

      expect(instance).to respond_to(:resource_params, true).with(0).arguments
    end # it

    it { expect(instance.send :resource_params).to be == {} }

    context 'when the resource params are empty' do
      let(:params) { super().merge :book => {} }

      it { expect(instance.send :resource_params).to be == {} }
    end # context

    context 'when the resource params have attributes' do
      let(:attributes) do
        {
          :title      => 'The Hobbit',
          :series     => 'The Lord of the Rings',
          :page_count => 320
        } # end attributes
      end # let
      let(:params) { super().merge :book => attributes }

      it { expect(instance.send :resource_params).to be == {} }

      wrap_context 'when a subset of attributes are permitted' do
        let(:expected) do
          {
            'title'  => attributes[:title],
            'series' => attributes[:series]
          } # end expected attributes
        end # let

        it { expect(instance.send :resource_params).to be == expected }
      end # wrap_context

      wrap_context 'when all attributes are permitted' do
        let(:expected) do
          {
            'title'      => attributes[:title],
            'series'     => attributes[:series],
            'page_count' => attributes[:page_count]
          } # end expected attributes
        end # let

        it { expect(instance.send :resource_params).to be == expected }
      end # wrap_context
    end # context
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
