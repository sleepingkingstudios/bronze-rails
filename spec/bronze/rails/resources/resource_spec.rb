# spec/bronze/rails/resources/resource_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'

require 'fixtures/entities/archived_periodical'
require 'fixtures/entities/book'

RSpec.describe Bronze::Rails::Resources::Resource do
  shared_context 'when the resource class has a compound name' do
    let(:resource_class) { Spec::ArchivedPeriodical }
  end # shared_context

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new resource_class, resource_options
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  describe '#collection_name' do
    include_examples 'should have reader',
      :collection_name,
      ->() { be == 'spec-books' }

    wrap_context 'when the resource class has a compound name' do
      it 'should return the collection name' do
        expect(instance.collection_name).to be == 'spec-archived_periodicals'
      end # it
    end # wrap_context
  end # describe

  describe '#edit_template' do
    include_examples 'should have reader',
      :edit_template,
      ->() { be == 'books/edit' }
  end # describe

  describe '#index_template' do
    include_examples 'should have reader',
      :index_template,
      ->() { be == 'books/index' }
  end # describe

  describe '#new_template' do
    include_examples 'should have reader',
      :new_template,
      ->() { be == 'books/new' }
  end # describe

  describe '#plural_resource_key' do
    include_examples 'should have reader', :plural_resource_key, :books

    wrap_context 'when the resource class has a compound name' do
      it 'should return the plural resource key' do
        expect(instance.plural_resource_key).to be == :archived_periodicals
      end # it
    end # wrap_context
  end # describe

  describe '#plural_resource_name' do
    include_examples 'should have reader',
      :plural_resource_name,
      ->() { be == 'books' }

    wrap_context 'when the resource class has a compound name' do
      it 'should return the plural resource name' do
        expect(instance.plural_resource_name).to be == 'archived_periodicals'
      end # it
    end # wrap_context
  end # describe

  describe '#qualified_resource_name' do
    include_examples 'should have reader',
      :qualified_resource_name,
      ->() { be == 'spec-book' }

    wrap_context 'when the resource class has a compound name' do
      it 'should return the qualified resource name' do
        expect(instance.qualified_resource_name).
          to be == 'spec-archived_periodical'
      end # it
    end # wrap_context
  end # describe

  describe '#resource_class' do
    include_examples 'should have reader',
      :resource_class,
      ->() { resource_class }
  end # describe

  describe '#resource_key' do
    include_examples 'should have reader', :resource_key, :book

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource key' do
        expect(instance.resource_key).to be == :archived_periodical
      end # it
    end # wrap_context
  end # describe

  describe '#resource_name' do
    include_examples 'should have reader',
      :resource_name,
      ->() { be == 'book' }

    wrap_context 'when the resource class has a compound name' do
      it 'should return the resource name' do
        expect(instance.resource_name).to be == 'archived_periodical'
      end # it
    end # wrap_context
  end # describe

  describe '#resource_options' do
    include_examples 'should have reader',
      :resource_options,
      ->() { resource_options }
  end # describe

  describe '#resource_path' do
    let(:book) { Spec::Book.new }

    it { expect(instance).to respond_to(:resource_path).with(1).arguments }

    describe 'with a resource id' do
      it { expect(instance.resource_path book.id).to be == "/books/#{book.id}" }
    end # describe

    describe 'with a resource instance' do
      it { expect(instance.resource_path book).to be == "/books/#{book.id}" }
    end # describe
  end # describe

  describe '#resources_path' do
    it { expect(instance).to respond_to(:resources_path).with(0).arguments }

    it { expect(instance.resources_path).to be == '/books' }
  end # describe

  describe '#show_template' do
    include_examples 'should have reader',
      :show_template,
      ->() { be == 'books/show' }
  end # describe

  describe '#template' do
    it { expect(instance).to respond_to(:template).with(1).argument }

    describe 'with the name of an action' do
      let(:action) { 'defenestrate' }

      it { expect(instance.template action).to be == "books/#{action}" }
    end # describe
  end # describe
end # describe
