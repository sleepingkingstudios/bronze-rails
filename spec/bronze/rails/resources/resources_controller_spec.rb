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

    let(:action_name) { action_name }
    let(:operation)   { Spec::Operation.new.execute }
    let(:response)    { double('response') }

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

  describe '::included' do
    let(:described_class) { Class.new(Spec::Controller) }
    let(:primary_callback) do
      {
        :method_name => :require_primary_resource,
        :options     => { :only => %i(update destroy) }
      } # end callback
    end # let

    it 'should set the before_action callback' do
      expect do
        described_class.send :include,
          Bronze::Rails::Resources::ResourcesController
      end. # expect
        to change { described_class.callbacks[:before] }.
        to include primary_callback
    end # it
  end # describe

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

  describe '#update' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:update).with(0).arguments }

    include_examples 'should delegate to the operation', :update
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
        to receive(:build_one).
        with(resource_class, instance.send(:resource_params)).
        and_return(build_operation)

      expect(instance).
        to receive(:validate_one).
        with(build_operation.resource).
        and_return(validate_operation)

      expect(instance).
        to receive(:insert_one).
        with(resource_class, validate_operation.resource).
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
        to receive(:find_one).
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
        to receive(:find_matching).
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
        to receive(:build_one).
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
        to receive(:find_one).
        with(resource_class, params[:id]).
        and_return(operation)

      expect(instance.send :show_resource).to be operation
    end # it
  end # describe

  describe '#update_resource' do
    include_context 'when the resource is defined'

    let(:resource) { Spec::Book.new }
    let(:assign_operation) do
      Spec::Operation.new(:resources => [resource]).execute
    end # let
    let(:validate_operation) do
      Spec::Operation.new(:resources => [resource]).execute
    end # let
    let(:update_operation) do
      Spec::Operation.new(:resources => [resource]).execute
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:update_resource)

      expect(instance).
        to respond_to(:update_resource, true).
        with(0).arguments
    end # it

    it 'should assign, validate and update the resource' do
      instance.send :primary_resource=, resource

      expect(instance).
        to receive(:assign_one).
        with(resource, instance.send(:resource_params)).
        and_return(assign_operation)

      expect(instance).
        to receive(:validate_one).
        with(assign_operation.resource).
        and_return(validate_operation)

      expect(instance).
        to receive(:update_one).
        with(resource_class, validate_operation.resource).
        and_return(update_operation)

      expect(instance.send :update_resource).to be update_operation
    end # it
  end # describe

  ##############################################################################
  ###                               Callbacks                                ###
  ##############################################################################

  describe '#require_one' do
    include_context 'when the resource is defined'

    let(:resource)  { Spec::Book.new }
    let(:operation) { Spec::Operation.new(:resources => [resource]).execute }
    let(:params)    { super().merge :id => resource.id }
    let(:resource_definition) do
      described_class.resource_definition
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:require_one)

      expect(instance).
        to respond_to(:require_one, true).
        with(2).arguments
    end # it

    it 'should find the resource' do
      expect(instance).
        to receive(:find_one).
        with(resource_class, params[:id]).
        and_return(operation)

      expect(
        instance.send :require_one, resource_definition, params[:id]
      ).to be operation
    end # it

    context 'when the resource is missing' do
      let(:operation) { super().fail! }

      it 'should redirect to the resources path' do
        allow(instance).to receive(:redirect_to).and_call_original

        expect(instance).
          to receive(:find_one).
          with(resource_class, params[:id]).
          and_return(operation)

        expect(
          instance.send :require_one, resource_definition, params[:id]
        ).to be operation

        expect(instance).to have_received(:redirect_to) { |path|
          expect(path).to be == resource_definition.resources_path
        } # end redirect_to options
      end # it
    end # context
  end # describe

  describe '#require_primary_resource' do
    include_context 'when the resource is defined'

    let(:resource)  { Spec::Book.new }
    let(:operation) { Spec::Operation.new(:resources => [resource]).execute }
    let(:resource_definition) do
      described_class.resource_definition
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:require_primary_resource)

      expect(instance).
        to respond_to(:require_primary_resource, true).
        with(0).arguments
    end # it

    it 'should find and assign the resource' do
      expect(instance).
        to receive(:require_one).
        with(resource_definition, params[:id]).
        and_return(operation)

      result = nil

      expect { result = instance.send :require_primary_resource }.
        to change(instance, :primary_resource).
        to be operation.resource

      expect(result).to be operation
    end # it
  end # describe

  ##############################################################################
  ###                               Operations                               ###
  ##############################################################################

  describe '#assign_one' do
    let(:resource)   { Spec::Book.new }
    let(:attributes) { {} }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:assign_one)

      expect(instance).
        to respond_to(:assign_one, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :assign_one, resource, attributes

      expect(operation).
        to be_a Patina::Operations::Entities::AssignOneOperation
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#build_one' do
    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_one)

      expect(instance).
        to respond_to(:build_one, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :build_one, resource_class, {}

      expect(operation).
        to be_a Patina::Operations::Entities::BuildOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#find_matching' do
    it 'should define the private method' do
      expect(instance).not_to respond_to(:find_matching)

      expect(instance).
        to respond_to(:find_matching, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :find_matching, resource_class, {}

      expect(operation).
        to be_a Patina::Operations::Entities::FindMatchingOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#find_one' do
    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:find_one)

      expect(instance).
        to respond_to(:find_one, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :find_one, resource_class, resource.id

      expect(operation).
        to be_a Patina::Operations::Entities::FindOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#insert_one' do
    include_context 'when the resource is defined'

    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:insert_one)

      expect(instance).
        to respond_to(:insert_one, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :insert_one, resource_class, resource

      expect(operation).
        to be_a Patina::Operations::Entities::InsertOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#update_one' do
    include_context 'when the resource is defined'

    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:update_one)

      expect(instance).
        to respond_to(:update_one, true).
        with(2).arguments
    end # it

    it 'should return an operation' do
      operation = instance.send :update_one, resource_class, resource

      expect(operation).
        to be_a Patina::Operations::Entities::UpdateOneOperation
      expect(operation.resource_class).to be resource_class
      expect(operation.called?).to be true
    end # it
  end # describe

  describe '#validate_one' do
    let(:resource) { Spec::Book.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:validate_one)

      expect(instance).
        to respond_to(:validate_one, true).
        with(1).argument
    end # it

    it 'should return an operation' do
      operation = instance.send :validate_one, resource

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

  describe '#primary_resource' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:primary_resource)

      expect(instance).to respond_to(:primary_resource, true).with(0).arguments
    end # it

    it { expect(instance.send :primary_resource).to be nil }
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
