# spec/bronze/rails/resources/resource/builder_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource/builder'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource::Builder do
  shared_context 'when the resource has many namespaces' do
    before(:example) do
      instance.namespace :admin
      instance.namespace :api
    end # before example
  end # shared_context

  shared_context 'when the resource has a namespace and a parent resource' do
    let(:book)           { Spec::Book.new }
    let(:resource_class) { Spec::Chapter }

    before(:example) do
      instance.namespace       :admin
      instance.parent_resource Spec::Book
    end # before example
  end # shared_context

  shared_context 'when the resource has many parent resources' do
    let(:book)           { Spec::Book.new }
    let(:chapter)        { Spec::Chapter.new }
    let(:resource_class) { Spec::Section }

    before(:example) do
      instance.parent_resource Spec::Book
      instance.parent_resource Spec::Chapter
    end # before example
  end # shared_context

  let(:resource_class) { Spec::Book }
  let(:resource) do
    Bronze::Rails::Resources::Resource.new(resource_class)
  end # let
  let(:instance) { described_class.new(resource) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#namespace' do
    shared_examples 'should add the namespace to the resource' do
      it 'should add the namespace to the resource' do
        expect { instance.namespace name }.
          to change(resource.namespaces, :count).by(1)

        namespace = resource.namespaces.last
        expect(namespace.fetch :name).to be == name.intern
        expect(namespace.fetch :type).to be :namespace
      end # it
    end # shared_examples

    let(:name) { 'alpha' }

    it { expect(instance).to respond_to(:namespace).with(1).argument }

    include_examples 'should add the namespace to the resource'

    wrap_context 'when the resource has many namespaces' do
      include_examples 'should add the namespace to the resource'
    end # wrap-context

    wrap_context 'when the resource has a namespace and a parent resource' do
      include_examples 'should add the namespace to the resource'
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      include_examples 'should add the namespace to the resource'
    end # wrap_context
  end # describe

  describe '#parent_resource' do
    shared_examples 'should add the parent to the resource' do |proc|
      describe 'with a resource class' do
        it 'should add the parent to the resource' do
          expect { instance.parent_resource parent_class, parent_options }.
            to change(resource.namespaces, :count).by(1)

          namespace = resource.namespaces.last
          expect(namespace.fetch :name).to be == parent_name.intern
          expect(namespace.fetch :type).to be :resource

          parent_resource = namespace.fetch :resource
          expect(parent_resource.plural_resource_name).to be == parent_name
          expect(parent_resource.resource_class).to be parent_class

          instance_exec(parent_resource, &proc) if proc
        end # it
      end # describe

      describe 'with a resource name' do
        let(:parent_class)   { Audiobook }
        let(:parent_name)    { 'audiobooks' }

        example_class 'Audiobook', :base_class => Bronze::Entities::Entity

        it 'should add the parent to the resource' do
          expect { instance.parent_resource parent_name, parent_options }.
            to change(resource.namespaces, :count).by(1)

          namespace = resource.namespaces.last
          expect(namespace.fetch :name).to be == parent_name.intern
          expect(namespace.fetch :type).to be :resource

          parent_resource = namespace.fetch :resource
          expect(parent_resource.plural_resource_name).to be == parent_name
          expect(parent_resource.resource_class).to be parent_class

          instance_exec(parent_resource, &proc) if proc
        end # it
      end # describe

      describe 'with a resource name and :class => parent_class' do
        let(:parent_name)    { 'books' }
        let(:parent_options) { super().merge :class => parent_class }

        it 'should add the parent to the resource' do
          expect { instance.parent_resource parent_name, parent_options }.
            to change(resource.namespaces, :count).by(1)

          namespace = resource.namespaces.last
          expect(namespace.fetch :name).to be == parent_name.intern
          expect(namespace.fetch :type).to be :resource

          parent_resource = namespace.fetch :resource
          expect(parent_resource.plural_resource_name).to be == parent_name
          expect(parent_resource.resource_class).to be parent_class

          instance_exec(parent_resource, &proc) if proc
        end # it
      end # describe
    end # shared_examples

    let(:parent_class)   { Spec::Book }
    let(:parent_options) { {} }
    let(:parent_name)    { 'books' }

    it 'should define the method' do
      expect(instance).to respond_to(:parent_resource).with(1..2).arguments
    end # it

    include_examples 'should add the parent to the resource'

    wrap_context 'when the resource has many namespaces' do
      include_examples 'should add the parent to the resource'
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' do
      include_examples 'should add the parent to the resource'
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      include_examples 'should add the parent to the resource'
    end # wrap_context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, ->() { resource }
  end # describe
end # describe
