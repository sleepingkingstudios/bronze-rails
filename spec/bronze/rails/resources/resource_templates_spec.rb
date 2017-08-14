# spec/bronze/rails/resources/resource_templates_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource_templates'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::ResourceTemplates do
  shared_context 'when the resource has many namespaces' do
    let(:resource_block) do
      lambda do
        namespace :admin
        namespace :api
      end # lambda
    end # let
  end # shared_context

  shared_context 'when the resource has a namespace and a parent resource' do
    let(:book)           { Spec::Book.new }
    let(:resource_class) { Spec::Chapter }
    let(:resource_block) do
      lambda do
        namespace       :admin
        parent_resource Spec::Book
      end # lambda
    end # let
  end # shared_context

  shared_context 'when the resource has many parent resources' do
    let(:book)           { Spec::Book.new }
    let(:chapter)        { Spec::Chapter.new }
    let(:resource_class) { Spec::Section }
    let(:resource_block) do
      lambda do
        parent_resource Spec::Book
        parent_resource Spec::Chapter
      end # lambda
    end # let
  end # shared_context

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_block)   { ->() {} }
  let(:resource) do
    Bronze::Rails::Resources::Resource.new(
      resource_class,
      resource_options,
      &resource_block
    ) # end resource
  end # let
  let(:instance) { described_class.new(resource) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#edit_template' do
    include_examples 'should have reader',
      :edit_template,
      ->() { be == instance.template(:edit) }
  end # describe

  describe '#index_template' do
    include_examples 'should have reader',
      :index_template,
      ->() { be == instance.template(:index) }
  end # describe

  describe '#new_template' do
    include_examples 'should have reader',
      :new_template,
      ->() { be == instance.template(:new) }
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, ->() { resource }
  end # describe

  describe '#show_template' do
    include_examples 'should have reader',
      :show_template,
      ->() { be == instance.template(:show) }
  end # describe

  describe '#template' do
    let(:action_name) { 'read' }
    let(:expected)    { 'books/read' }

    it { expect(instance).to respond_to(:template).with(1).argument }

    it { expect(instance.template action_name).to be == expected }

    context 'when resource#controller_name is set' do
      let(:resource_options) do
        super().merge :controller_name => 'TomesController'
      end # let
      let(:expected) { 'tomes/read' }

      it { expect(instance.template action_name).to be == expected }
    end # context

    wrap_context 'when the resource has many namespaces' do
      let(:expected) { 'admin/api/books/read' }

      it { expect(instance.template action_name).to be == expected }

      context 'when options[:controller_name] is set' do
        let(:resource_options) do
          super().merge :controller_name => 'TomesController'
        end # let
        let(:expected) { 'admin/api/tomes/read' }

        it { expect(instance.template action_name).to be == expected }
      end # context
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      let(:expected) { 'admin/chapters/read' }

      it { expect(instance.template action_name).to be == expected }

      context 'when options[:controller_name] is set' do
        let(:resource_options) do
          super().merge :controller_name => 'EpisodesController'
        end # let
        let(:expected) { 'admin/episodes/read' }

        it { expect(instance.template action_name).to be == expected }
      end # context
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:expected) { 'sections/read' }

      it { expect(instance.template action_name).to be == expected }

      context 'when options[:controller_name] is set' do
        let(:resource_options) do
          super().merge :controller_name => 'PassagesController'
        end # let
        let(:expected) { 'passages/read' }

        it { expect(instance.template action_name).to be == expected }
      end # context
    end # wrap_context
  end # describe
end # describe
