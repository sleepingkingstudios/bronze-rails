# spec/bronze/rails/resources/resources_controller_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/publisher'
require 'support/mocks/controller'
require 'support/mocks/operation'

RSpec.describe Bronze::Rails::Resources::ResourcesController do
  shared_context 'when the resource is defined' do
    before(:example) do
      described_class.resource resource_class, resource_options, &resource_block
    end # before example
  end # shared_context

  shared_context 'when the resource has a parent resource' do
    let(:resource_block) do
      lambda do
        parent_resource :publishers, :class => Spec::Publisher
      end # lambda
    end # let
  end # shared_context

  shared_context 'when the resource exists in the repository' do
    let(:initial_attributes) do
      {
        :title  => 'Beyond The Farthest Star',
        :series => 'Collected Works'
      } # attributes
    end # let
    let(:resource) { Spec::Book.new(initial_attributes) }

    before(:example) do
      repository = instance.send(:repository)

      repository.collection(Spec::Book).insert(resource)
    end # before example
  end # shared_context

  shared_context 'when many resources exist in the repository' do
    let(:initial_attributes) do
      [
        {
          :title  => 'Pirates of Venus',
          :series => 'Venus'
        }, # attributes
        {
          :title  => 'Lost on Venus',
          :series => 'Venus'
        }, # attributes
        {
          :title  => 'Carson of Venus',
          :series => 'Venus'
        }, # attributes
        {
          :title  => 'The Land That Time Forgot',
          :series => 'Caspak'
        }, # attributes
        {
          :title  => 'The People That Time Forgot',
          :series => 'Caspak'
        }, # attributes
        {
          :title  => "Out of Time's Abyss",
          :series => 'Caspak'
        } # attributes
      ] # end array
    end # let
    let(:resources) { initial_attributes.map { |hsh| Spec::Book.new(hsh) } }

    before(:example) do
      repository = instance.send(:repository)

      resources.each do |resource|
        repository.collection(Spec::Book).insert(resource)
      end # each
    end # before example
  end # shared_context

  shared_context 'when the parent resource exists in the repository' do
    let(:parent_attributes) { { :name => 'Amazing Stories' } }
    let(:parent_resource)   { Spec::Publisher.new(parent_attributes) }

    before(:example) do
      repository = instance.send(:repository)

      repository.collection(Spec::Publisher).insert(parent_resource)
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
    let(:responder)   { double('responder') }
    let(:response)    { double('response') }

    it "should delegate to the ##{operation_name} operation" do
      expect(instance).
        to receive(operation_name).
        with(no_args).
        and_return(operation)

      expect(instance).
        to receive(:build_responder).
        with(no_args).
        and_return(responder)

      expect(responder).
        to receive(:call).
        with(operation, :action => action_name)

      instance.send(action_name)
    end # it
  end # shared_examples

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_block)   { ->() {} }
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
    let(:parents_callback) do
      {
        :method_name => :require_parent_resources,
        :options     => {}
      } # end callback
    end # let
    let(:primary_callback) do
      {
        :method_name => :require_primary_resource,
        :options     => { :only => %i(show edit update destroy) }
      } # end callback
    end # let

    it 'should set the before_action callback' do
      expect do
        described_class.send :include,
          Bronze::Rails::Resources::ResourcesController
      end. # expect
        to change { described_class.callbacks[:before] }.
        to be == [parents_callback, primary_callback]
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

  describe '#destroy' do
    include_context 'when the resource is defined'

    it { expect(instance).to respond_to(:destroy).with(0).arguments }

    include_examples 'should delegate to the operation', :destroy
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
    include_context 'when all attributes are permitted'

    describe 'with empty params' do
      it 'should build and validate but not insert the resource' do
        operation  = instance.send(:create_resource)
        repository = instance.send(:repository)

        expect(operation).
          to be_a Bronze::Entities::Operations::BuildAndInsertOneOperation
        expect(operation.entity_class).to be resource_class
        expect(operation.repository).to be repository
        expect(operation.called?).to be true
        expect(operation.success?).to be false
        expect(operation.result).to be_a resource_class
        expect(operation.result.persisted?).to be false

        persisted =
          repository.collection(resource_class).find(operation.result.id)
        expect(persisted).to be nil
      end # it
    end # describe

    describe 'with invalid params' do
      let(:initial_attributes) do
        {
          :title  => nil,
          :series => 'Lost Works'
        } # end let
      end # let
      let(:params) { super().merge :book => initial_attributes }

      it 'should build and validate but not insert the resource' do
        operation  = instance.send(:create_resource)
        repository = instance.send(:repository)

        expect(operation).
          to be_a Bronze::Entities::Operations::BuildAndInsertOneOperation
        expect(operation.entity_class).to be resource_class
        expect(operation.repository).to be repository
        expect(operation.called?).to be true
        expect(operation.success?).to be false
        expect(operation.result).to be_a resource_class
        expect(operation.result.persisted?).to be false

        persisted =
          repository.collection(resource_class).find(operation.result.id)
        expect(persisted).to be nil
      end # it
    end # describe

    describe 'with valid params' do
      let(:initial_attributes) do
        {
          :title  => 'The Moon Maid',
          :series => 'Collected Works'
        } # end let
      end # let
      let(:params) { super().merge :book => initial_attributes }

      it 'should build, validate, and insert the resource' do
        operation  = instance.send(:create_resource)
        repository = instance.send(:repository)

        expect(operation).
          to be_a Bronze::Entities::Operations::BuildAndInsertOneOperation
        expect(operation.entity_class).to be resource_class
        expect(operation.repository).to be repository
        expect(operation.called?).to be true
        expect(operation.success?).to be true
        expect(operation.result).to be_a resource_class
        expect(operation.result.persisted?).to be true
        expect(operation.result.attributes).to be >= initial_attributes

        persisted =
          repository.collection(resource_class).find(operation.result.id)
        expect(persisted.attributes).to be >= initial_attributes
      end # it
    end # describe

    wrap_context 'when the resource has a parent resource' do
      include_context 'when the parent resource exists in the repository'

      let(:params) { super().merge :publisher_id => parent_resource.id }

      before(:example) { instance.send :require_parent_resources }

      describe 'with invalid params' do
        let(:initial_attributes) do
          {
            :title  => nil,
            :series => 'Lost Works'
          } # end let
        end # let
        let(:params) { super().merge :book => initial_attributes }

        it 'should build and validate but not insert the resource' do
          operation  = instance.send(:create_resource)
          repository = instance.send(:repository)

          expect(operation).
            to be_a Bronze::Entities::Operations::BuildAndInsertOneOperation
          expect(operation.entity_class).to be resource_class
          expect(operation.repository).to be repository
          expect(operation.called?).to be true
          expect(operation.success?).to be false
          expect(operation.result).to be_a resource_class
          expect(operation.result.persisted?).to be false
          expect(operation.result.publisher).to be == parent_resource

          persisted =
            repository.collection(resource_class).find(operation.result.id)
          expect(persisted).to be nil
        end # it
      end # describe

      describe 'with valid params' do
        let(:initial_attributes) do
          {
            :title  => 'The Moon Maid',
            :series => 'Collected Works'
          } # end let
        end # let
        let(:params) { super().merge :book => initial_attributes }

        it 'should build, validate, and insert the resource' do
          operation  = instance.send(:create_resource)
          repository = instance.send(:repository)

          expect(operation).
            to be_a Bronze::Entities::Operations::BuildAndInsertOneOperation
          expect(operation.entity_class).to be resource_class
          expect(operation.repository).to be repository
          expect(operation.called?).to be true
          expect(operation.success?).to be true
          expect(operation.result).to be_a resource_class
          expect(operation.result.persisted?).to be true
          expect(operation.result.attributes).to be >= initial_attributes
          expect(operation.result.publisher).to be == parent_resource

          persisted =
            repository.collection(resource_class).find(operation.result.id)
          expect(persisted.attributes).to be >= initial_attributes
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#destroy_resource' do
    include_context 'when the resource is defined'
    include_context 'when the resource exists in the repository'

    let(:params) { super().merge :id => resource.id }

    before(:example) { instance.send :require_primary_resource }

    it 'should delete the resource' do
      operation  = instance.send(:destroy_resource)
      repository = instance.send(:repository)

      expect(operation).to be_a Bronze::Operations::OperationChain
      expect(operation.called?).to be true
      expect(operation.success?).to be true

      persisted = repository.collection(resource_class).find(resource.id)
      expect(persisted).to be nil
    end # it

    context 'when the destroy operation fails' do
      before(:example) do
        repository = instance.send(:repository)

        repository.collection(resource_class).delete(resource.id)
      end # before example

      it 'should fail with errors' do
        operation = instance.send(:destroy_resource)

        expect(operation).to be_a Bronze::Operations::OperationChain
        expect(operation.called?).to be true
        expect(operation.success?).to be false

        expect(operation.errors[:book]).not_to be_empty
      end # it

      context 'when the resource has a custom name' do
        let(:resource_options) { super().merge :resource_name => 'tome' }

        it 'should fail with errors' do
          operation = instance.send(:destroy_resource)

          expect(operation).to be_a Bronze::Operations::OperationChain
          expect(operation.called?).to be true
          expect(operation.success?).to be false

          expect(operation.errors[:tome]).not_to be_empty
        end # it
      end # context
    end # context
  end # describe

  describe '#edit_resource' do
    include_context 'when the resource is defined'
    include_context 'when the resource exists in the repository'

    let(:params) { super().merge :id => resource.id }

    before(:example) { instance.send :require_primary_resource }

    it 'should return the resource' do
      operation = instance.send(:edit_resource)

      expect(operation.called?).to be true
      expect(operation.result).to be == resource
    end # it

    wrap_context 'when the resource has a parent resource' do
      include_context 'when the parent resource exists in the repository'

      let(:initial_attributes) do
        super().merge :publisher_id => parent_resource.id
      end # let
      let(:params) { super().merge :publisher_id => parent_resource.id }

      before(:example) { instance.send :require_parent_resources }

      it 'should return the resource' do
        operation = instance.send(:edit_resource)

        expect(operation.called?).to be true
        expect(operation.result).to be == resource
        expect(operation.result.publisher).to be == parent_resource
      end # it
    end # wrap_context
  end # describe

  describe '#index_resources' do
    include_context 'when the resource is defined'
    include_context 'when many resources exist in the repository'

    it 'should filter the resources' do
      operation = instance.send(:index_resources)

      expect(operation).to be_a Bronze::Operations::OperationChain
      expect(operation.called?).to be true
      expect(operation.success?).to be true
      expect(operation.result).to be == resources
    end # it

    describe 'with :matching => selector' do
      let(:selector) { { :series => 'Venus' } }
      let(:params)   { super().merge :matching => selector }
      let(:expected) { resources.select { |obj| obj.series == 'Venus' } }

      it 'should filter the resources' do
        operation = instance.send(:index_resources)

        expect(operation).to be_a Bronze::Operations::OperationChain
        expect(operation.called?).to be true
        expect(operation.success?).to be true
        expect(operation.result).to contain_exactly(*expected)
      end # it
    end # describe

    wrap_context 'when the resource has a parent resource' do
      include_context 'when the parent resource exists in the repository'

      let(:initial_attributes) do
        super().map { |hsh| hsh.merge :publisher_id => parent_resource.id }
      end # let
      let(:params) { super().merge :publisher_id => parent_resource.id }

      before(:example) do
        instance.send :require_parent_resources
      end # before example

      it 'should assign the parent resource' do
        operation = instance.send(:index_resources)

        expect(operation).to be_a Bronze::Operations::OperationChain
        expect(operation.called?).to be true
        expect(operation.success?).to be true
        expect(operation.result).to contain_exactly(*resources)

        operation.result.each do |book|
          expect(book.publisher).to be == parent_resource
        end # each
      end # it
    end # wrap_context
  end # describe

  describe '#new_resource' do
    include_context 'when the resource is defined'
    include_context 'when all attributes are permitted'

    let(:initial_attributes) do
      {
        :title  => 'Tales of Three Planets',
        :series => 'Collected Works'
      } # end let
    end # let
    let(:params) { super().merge :book => initial_attributes }

    it 'should build the resource' do
      operation = instance.send(:new_resource)

      expect(operation).
        to be_a Bronze::Entities::Operations::BuildOneOperation
      expect(operation.entity_class).to be resource_class
      expect(operation.called?).to be true
      expect(operation.result).to be_a resource_class
      expect(operation.result.persisted?).to be false
      expect(operation.result.attributes).to be >= initial_attributes
    end # it
  end # describe

  describe '#show_resource' do
    include_context 'when the resource is defined'
    include_context 'when the resource exists in the repository'

    let(:params) { super().merge :id => resource.id }

    before(:example) { instance.send :require_primary_resource }

    it 'should return the resource' do
      operation = instance.send(:show_resource)

      expect(operation.called?).to be true
      expect(operation.result).to be == resource
    end # it

    wrap_context 'when the resource has a parent resource' do
      include_context 'when the parent resource exists in the repository'

      let(:initial_attributes) do
        super().merge :publisher_id => parent_resource.id
      end # let
      let(:params) { super().merge :publisher_id => parent_resource.id }

      before(:example) { instance.send :require_parent_resources }

      it 'should return the resource' do
        operation = instance.send(:show_resource)

        expect(operation.called?).to be true
        expect(operation.result).to be == resource
        expect(operation.result.publisher).to be == parent_resource
      end # it
    end # wrap_context
  end # describe

  describe '#update_resource' do
    include_context 'when the resource is defined'
    include_context 'when the resource exists in the repository'
    include_context 'when all attributes are permitted'

    let(:attributes) { {} }
    let(:params)     { super().merge :id => resource.id, :book => attributes }

    before(:example) { instance.send :require_primary_resource }

    describe 'with invalid params' do
      let(:attributes) { { :title => nil } }

      it 'should assign, validate, and update the resource' do
        operation  = instance.send(:update_resource)
        repository = instance.send(:repository)

        expect(operation).
          to be_a Bronze::Entities::Operations::AssignAndUpdateOneOperation
        expect(operation.entity_class).to be resource_class
        expect(operation.repository).to be repository
        expect(operation.called?).to be true
        expect(operation.success?).to be false
        expect(operation.result).to be_a resource_class
        expect(operation.result.id).to be == resource.id
        expect(operation.result.attributes_changed?).to be true
        expect(operation.result.persisted?).to be true
        expect(operation.result.attributes).to be >= attributes

        persisted = repository.collection(resource_class).find(resource.id)
        expect(persisted.attributes).to be >= initial_attributes
      end # it
    end # describe

    describe 'with valid params' do
      let(:attributes) { { :title => 'The Oakdale Affair' } }

      it 'should assign, validate, and update the resource' do
        operation  = instance.send(:update_resource)
        repository = instance.send(:repository)

        expect(operation).
          to be_a Bronze::Entities::Operations::AssignAndUpdateOneOperation
        expect(operation.entity_class).to be resource_class
        expect(operation.repository).to be repository
        expect(operation.called?).to be true
        expect(operation.success?).to be true
        expect(operation.result).to be_a resource_class
        expect(operation.result.id).to be == resource.id
        expect(operation.result.attributes_changed?).to be false
        expect(operation.result.persisted?).to be true
        expect(operation.result.attributes).to be >= attributes

        persisted = repository.collection(resource_class).find(resource.id)
        expect(persisted.attributes).to be >= attributes
      end # it
    end # describe
  end # describe

  ##############################################################################
  ###                               Callbacks                                ###
  ##############################################################################

  describe '#require_parent_resources' do
    include_context 'when the resource is defined'

    it 'should define the private method' do
      expect(instance).not_to respond_to(:require_parent_resources)

      expect(instance).
        to respond_to(:require_parent_resources, true).
        with(0).arguments
    end # it

    it 'should be a null operation' do
      operation = instance.send :require_parent_resources

      expect(operation).to be_a Bronze::Operations::NullOperation
      expect(operation.called?).to be true
      expect(operation.success?).to be true
      expect(operation.result).to be nil
    end # it

    wrap_context 'when the resource has a parent resource' do
      it 'should fail with a missing resource error' do
        operation = instance.send :require_parent_resources

        expect(operation).to be_a Bronze::Operations::OperationChain
        expect(operation.called?).to be true
        expect(operation.success?).to be false
        expect(operation.result).to be nil
      end # it

      wrap_context 'when the parent resource exists in the repository' do
        let(:params) { super().merge :publisher_id => parent_resource.id }

        it 'should find and assign the parent resource' do
          operation = instance.send :require_parent_resources

          expect(operation).to be_a Bronze::Operations::OperationChain
          expect(operation.called?).to be true
          expect(operation.success?).to be true
          expect(operation.result).to be == parent_resource
        end # it

        it 'should assign the parent resource to #resources' do
          instance.send :require_parent_resources

          expect(instance.send(:resources).fetch(:publisher)).
            to be == parent_resource
        end # it
      end # wrap_context
    end # wrap_context
  end # describe

  describe '#require_primary_resource' do
    include_context 'when the resource is defined'

    let(:resource) { Spec::Book.new }
    let(:params)   { super().merge :id => resource.id }
    let(:resource_definition) do
      described_class.resource_definition
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:require_primary_resource)

      expect(instance).
        to respond_to(:require_primary_resource, true).
        with(0).arguments
    end # it

    it 'should not find the resource' do
      operation = instance.send(:require_primary_resource)

      expect(operation).to be_a Bronze::Operations::OperationChain
      expect(operation.called?).to be true
      expect(operation.success?).to be false
      expect(operation.result).to be nil

      resources = instance.send(:resources)

      expect(resources).to be_empty
    end # it

    it 'should call the responder with :action => :not_found' do
      responder = double('responder', :call => nil)
      expect(responder).to receive(:call).with(:action => :not_found)

      allow(instance).
        to receive(:build_responder).
        with(resource_definition).
        and_return(responder)

      instance.send(:require_primary_resource)
    end # it

    wrap_context 'when the resource exists in the repository' do
      it 'should find the resource' do
        operation = instance.send(:require_primary_resource)

        expect(operation).to be_a Bronze::Operations::OperationChain
        expect(operation.called?).to be true
        expect(operation.success?).to be true
        expect(operation.result).to be == resource

        resources = instance.send(:resources)

        expect(resources[:book]).to be == resource
        expect(resources[:book].persisted?).to be true
      end # it

      it 'should not call the responder' do
        expect(instance).not_to receive(:build_responder)

        instance.send(:require_primary_resource)
      end # it
    end # wrap_context
  end # describe

  ##############################################################################
  ###                               Operations                               ###
  ##############################################################################

  describe '#require_one' do
    include_context 'when the resource is defined'

    let(:resource) { Spec::Book.new }
    let(:params)   { super().merge :id => resource.id }
    let(:resource_definition) do
      described_class.resource_definition
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:require_one)

      expect(instance).to respond_to(:require_one, true).with(1).argument
    end # it

    it 'should not find the resource' do
      operation = instance.send(:require_one, resource_definition)

      expect(operation).to be_a Bronze::Operations::OperationChain

      operation.execute(resource.id)

      expect(operation.called?).to be true
      expect(operation.success?).to be false
      expect(operation.result).to be nil
    end # it

    it 'should call the responder with :action => :not_found' do
      responder = double('responder', :call => nil)
      expect(responder).to receive(:call).with(:action => :not_found)

      allow(instance).
        to receive(:build_responder).
        with(resource_definition).
        and_return(responder)

      operation = instance.send(:require_one, resource_definition)
      operation.execute(resource.id)
    end # it

    wrap_context 'when the resource exists in the repository' do
      it 'should find the resource' do
        operation = instance.send(:require_one, resource_definition)

        expect(operation).to be_a Bronze::Operations::OperationChain

        operation.execute(resource.id)

        expect(operation.called?).to be true
        expect(operation.success?).to be true
        expect(operation.result).to be == resource
        expect(operation.result.persisted?).to be true
      end # it

      it 'should not call the responder' do
        expect(instance).not_to receive(:build_responder)

        operation = instance.send(:require_one, resource_definition)
        operation.execute(resource.id)
      end # it
    end # wrap_context

    describe 'with a resource definition' do
      include_context 'when the resource has a parent resource'

      let(:parent_definition) do
        described_class.resource_definition.parent_resources.first
      end # let

      it 'should not find the resource' do
        operation = instance.send(:require_one, parent_definition)

        expect(operation).to be_a Bronze::Operations::OperationChain

        operation.execute(resource.id)

        expect(operation.called?).to be true
        expect(operation.success?).to be false
        expect(operation.result).to be nil
      end # it

      it 'should call the responder with :action => :not_found' do
        responder = double('responder', :call => nil)
        expect(responder).to receive(:call).with(:action => :not_found)

        allow(instance).
          to receive(:build_responder).
          with(parent_definition).
          and_return(responder)

        operation = instance.send(:require_one, parent_definition)
        operation.execute(resource.id)
      end # it

      wrap_context 'when the parent resource exists in the repository' do
        it 'should find the resource' do
          operation = instance.send(:require_one, parent_definition)

          expect(operation).to be_a Bronze::Operations::OperationChain

          operation.execute(parent_resource.id)

          expect(operation.called?).to be true
          expect(operation.success?).to be true
          expect(operation.result).to be == parent_resource
          expect(operation.result.persisted?).to be true
        end # it

        it 'should not call the responder' do
          expect(instance).not_to receive(:build_responder)

          operation = instance.send(:require_one, parent_definition)
          operation.execute(parent_resource.id)
        end # it
      end # context
    end # describe
  end # describe

  ##############################################################################
  ###                                 Helpers                                ###
  ##############################################################################

  describe '#assign_associations' do
    include_context 'when the resource is defined'

    it 'should define the private method' do
      expect(instance).not_to respond_to(:assign_associations)

      expect(instance).
        to respond_to(:assign_associations, true).
        with_unlimited_arguments
    end # it

    describe 'with one primary resource' do
      let(:primary_resource) { Spec::Book.new }

      it 'should not change the resource' do
        expect { instance.send :assign_associations, primary_resource }.
          not_to change { primary_resource }
      end # it
    end # describe

    describe 'with many primary resources' do
      let(:primary_resources) { Array.new(3) { Spec::Book.new } }

      it 'should not change the resource' do
        expect { instance.send(:assign_associations, *primary_resources) }.
          not_to change { primary_resources }
      end # it
    end # describe

    wrap_context 'when the resource has a parent resource' do
      let(:parent_resource) { Spec::Publisher.new }

      before(:example) do
        allow(instance).
          to receive(:resources).
          and_return(:publisher => parent_resource)
      end # before example

      describe 'with one primary resource' do
        let(:primary_resource) { Spec::Book.new }

        it 'should assign the associations to the primary resource' do
          instance.send :assign_associations, primary_resource

          expect(primary_resource.publisher).to be parent_resource
        end # it
      end # describe

      describe 'with many primary resources' do
        let(:primary_resources) { Array.new(3) { Spec::Book.new } }

        it 'should assign the associations to the primary resources' do
          instance.send(:assign_associations, *primary_resources)

          primary_resources.each do |primary_resource|
            expect(primary_resource.publisher).to be parent_resource
          end # each
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#build_responder' do
    include_context 'when the resource is defined'

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:build_responder)

      expect(instance).to respond_to(:build_responder, true).with(0).arguments
    end # it

    it 'should be a responder instance' do
      expect(Bronze::Rails::Responders::RenderViewResponder).
        to receive(:new).
        with(
          instance,
          instance.resource_definition,
          :resources      => instance.send(:resources),
          :resource_names => instance.send(:resource_names)
        ). # end arguments
        and_call_original

      responder = instance.send :build_responder

      expect(responder).to be_a Bronze::Rails::Responders::RenderViewResponder
      expect(responder.render_context).to be instance
    end # it

    describe 'with a resource definition' do
      include_context 'when the resource has a parent resource'

      it 'should be a responder instance' do
        parent_definition = instance.resource_definition.parent_resources.first

        expect(Bronze::Rails::Responders::RenderViewResponder).
          to receive(:new).
          with(
            instance,
            parent_definition,
            :resources      => instance.send(:resources),
            :resource_names => instance.send(:resource_names)
          ). # end arguments
          and_call_original

        responder = instance.send :build_responder, parent_definition

        expect(responder).to be_a Bronze::Rails::Responders::RenderViewResponder
        expect(responder.render_context).to be instance
      end # it
    end # describe
  end # describe

  describe '#filter_params' do
    include_context 'when the resource is defined'

    let(:expected) { { :matching => {} } }

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:filter_params)

      expect(instance).to respond_to(:filter_params, true).with(0).arguments
    end # it

    it { expect(instance.send :filter_params).to be == expected }

    describe 'with matching :title => value' do
      let(:params) do
        super().merge :matching => { :title => 'A Princess of Mars' }
      end # let
      let(:expected) { { :matching => { 'title' => 'A Princess of Mars' } } }

      it { expect(instance.send :filter_params).to be == expected }
    end # describe

    wrap_context 'when the resource has a parent resource' do
      let(:publisher) { Spec::Book.new }
      let(:params)    { super().merge :publisher_id => publisher.id }
      let(:expected)  { { :matching => { 'publisher_id' => publisher.id } } }

      it { expect(instance.send :filter_params).to be == expected }

      describe 'with matching :title => value' do
        let(:params) do
          super().merge :matching => { :title => 'A Princess of Mars' }
        end # let
        let(:expected) do
          {
            :matching => {
              'title'        => 'A Princess of Mars',
              'publisher_id' => publisher.id
            } # end matching
          } # end expected
        end # let

        it { expect(instance.send :filter_params).to be == expected }
      end # describe
    end # wrap_context
  end # describe

  describe '#map_errors' do
    include_context 'when the resource is defined'

    shared_examples 'should map the errors' do
      before(:example) do
        allow(operation).to receive(:result).and_return(result)
      end # before example

      it 'should map the errors' do
        expect(mapped).to be_a Bronze::Operations::Operation

        expect(mapped.called?).to be true
        expect(mapped.result).to be result
        expect(mapped.errors).to be == expected
      end # it
    end # shared_examples

    let(:operation) { Bronze::Operations::NullOperation.new.execute }
    let(:result)    { double('result') }
    let(:mapped)    { instance.send :map_errors, operation }
    let(:expected)  { Bronze::Errors.new }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:map_errors)

      expect(instance).to respond_to(:map_errors, true).with(1).argument
    end # it

    describe 'with an operation with no errors' do
      include_examples 'should map the errors'
    end # describe

    describe 'with an operation with general errors' do
      let(:expected) do
        super().add('errors.libraries.card_expired')
      end # let

      before(:example) do
        operation.errors.add('errors.libraries.card_expired')
      end # before example

      include_examples 'should map the errors'
    end # describe

    describe 'with an operation with resource errors' do
      let(:expected) do
        super().
          add('errors.libraries.card_expired').
          tap do |err|
            err[:book].add('errors.books.cover_missing')
            err[:book].add('errors.books.spine_bent')
          end # tap
      end # let

      before(:example) do
        operation.errors.add('errors.libraries.card_expired')
        operation.errors[:book].add('errors.books.cover_missing')
        operation.errors[:book].add('errors.books.spine_bent')
      end # before example

      include_examples 'should map the errors'
    end # describe

    context 'when the resource has a custom key' do
      let(:resource_options) { super().merge :resource_name => 'tome' }

      describe 'with an operation with no errors' do
        include_examples 'should map the errors'
      end # describe

      describe 'with an operation with general errors' do
        let(:expected) do
          super().add('errors.libraries.card_expired')
        end # let

        before(:example) do
          operation.errors.add('errors.libraries.card_expired')
        end # before example

        include_examples 'should map the errors'
      end # describe

      describe 'with an operation with resource errors' do
        let(:expected) do
          super().
            add('errors.libraries.card_expired').
            tap do |err|
              err[:tome].add('errors.books.cover_missing')
              err[:tome].add('errors.books.spine_bent')
            end # tap
        end # let

        before(:example) do
          operation.errors.add('errors.libraries.card_expired')
          operation.errors[:book].add('errors.books.cover_missing')
          operation.errors[:book].add('errors.books.spine_bent')
        end # before example

        include_examples 'should map the errors'
      end # describe
    end # context
  end # describe

  describe '#null_operation' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:null_operation)

      expect(instance).to respond_to(:null_operation, true).with(0).arguments
    end # it

    it 'should return a null operation' do
      expect(instance.send :null_operation).
        to be_a Bronze::Operations::NullOperation
    end # it
  end # descrbe

  describe '#operation_builder' do
    let(:error_message) { 'unknown builder strategy for nil' }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:operation_builder)

      expect(instance).
        to respond_to(:operation_builder, true).
        with(0..1).arguments
    end # it

    describe 'with no arguments' do
      it 'should raise an error' do
        expect { instance.send(:operation_builder) }.
          to raise_error ArgumentError, error_message
      end # it

      wrap_context 'when the resource is defined' do
        it 'should return an operation builder' do
          builder = instance.send(:operation_builder)

          expect(builder).
            to be_a Bronze::Entities::Operations::EntityOperationBuilder
          expect(builder.entity_class).to be resource_class
        end # it
      end # wrap_context
    end # describe

    describe 'with nil' do
      it 'should raise an error' do
        expect { instance.send(:operation_builder, nil) }.
          to raise_error ArgumentError, error_message
      end # it
    end # describe

    describe 'with a resource definition' do
      include_context 'when the resource is defined'

      it 'should return an operation builder' do
        resource_definition = described_class.resource_definition
        builder             =
          instance.send(:operation_builder, resource_definition)

        expect(builder).
          to be_a Bronze::Entities::Operations::EntityOperationBuilder
        expect(builder.entity_class).to be resource_class
      end # it

      wrap_context 'when the resource has a parent resource' do
        it 'should return an operation builder' do
          parent_definition =
            described_class.resource_definition.parent_resources.first
          builder           =
            instance.send(:operation_builder, parent_definition)

          expect(builder).
            to be_a Bronze::Entities::Operations::EntityOperationBuilder
          expect(builder.entity_class).to be parent_definition.resource_class
        end # it
      end # wrap_context
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
    include_context 'when the resource is defined'

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

    wrap_context 'when the resource has a parent resource' do
      let(:publisher) { Spec::Publisher.new }
      let(:expected)  { { 'publisher' => publisher } }

      before(:example) do
        instance.send(:resources).update(:publisher => publisher)
      end # before example

      it { expect(instance.send :resource_params).to be == expected }

      context 'when the resource params have attributes' do
        let(:attributes) do
          { :title => 'An Unexpected Party' }
        end # let
        let(:params) { super().merge :book => attributes }

        it { expect(instance.send :resource_params).to be == expected }

        wrap_context 'when all attributes are permitted' do
          let(:expected) do
            {
              'title'     => attributes[:title],
              'publisher' => publisher
            } # end expected attributes
          end # let

          it { expect(instance.send :resource_params).to be == expected }
        end # wrap_context
      end # context
    end # wrap_context
  end # describe

  describe '#resource_names' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:resource_names)

      expect(instance).to respond_to(:resource_names, true).with(0).arguments
    end # it

    it { expect(instance.send :resource_names).to be == [] }
  end # describe

  describe '#resources' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:resources)

      expect(instance).to respond_to(:resources, true).with(0).arguments
    end # it

    it { expect(instance.send :resources).to be == {} }
  end # describe
end # describe
