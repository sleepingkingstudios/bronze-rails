# spec/bronze/rails/resources/resource_spec.rb

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
end # describe
