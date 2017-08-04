# spec/bronze/rails/resources/resource_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource/base_examples'
require 'bronze/rails/resources/resource/names_examples'
require 'bronze/rails/resources/resource/routing_examples'
require 'bronze/rails/resources/resource/templates_examples'

require 'fixtures/entities/archived_periodical'
require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource do
  include Spec::Resources::Resource::BaseExamples
  include Spec::Resources::Resource::NamesExamples
  include Spec::Resources::Resource::RoutingExamples
  include Spec::Resources::Resource::TemplatesExamples

  shared_context 'when the resource has a parent resource' do
    let(:ancestors) do
      [
        {
          :name  => :books,
          :type  => :resource,
          :class => Spec::Book
        } # end books
      ] # end ancestors
    end # let
    let(:resource_class) { Spec::Chapter }
    let(:resource_options) do
      super().merge :ancestors => ancestors
    end # let
  end # shared_context

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:instance) do
    described_class.new resource_class, resource_options
  end # let

  include_examples 'should implement the Resource::Base methods'

  include_examples 'should implement the Resource::Names methods'

  include_examples 'should implement the Resource::Routing methods'

  include_examples 'should implement the Resource::Templates methods'

  describe '#association_key' do
    include_examples 'should have reader',
      :association_key,
      ->() { be == :books }

    context 'when options[:association_name] is set' do
      let(:resource_options) { super().merge :association_name => 'tomes' }

      it { expect(instance.association_key).to be == :tomes }
    end # context
  end # describe

  describe '#association_name' do
    include_examples 'should have reader',
      :association_name,
      ->() { be == 'books' }

    context 'when options[:association_name] is set' do
      let(:resource_options) { super().merge :association_name => 'tomes' }

      it { expect(instance.association_name).to be == 'tomes' }
    end # context
  end # describe

  describe '#foreign_key' do
    include_examples 'should have reader',
      :foreign_key,
      ->() { be == :book_id }

    context 'when options[:association_name] is set' do
      let(:resource_options) { super().merge :association_name => 'tomes' }

      it { expect(instance.foreign_key).to be == :tome_id }
    end # context

    context 'when options[:foreign_key] is set' do
      let(:resource_options) { super().merge :foreign_key => :tome_id }

      it { expect(instance.foreign_key).to be == :tome_id }
    end # context
  end # describe

  describe '#parent_resources' do
    include_examples 'should have reader', :parent_resources, []

    wrap_context 'when the resource has a parent resource' do
      it 'should return the parent resource', :aggregate_failures do
        expect(instance.parent_resources).to be_a Array
        expect(instance.parent_resources.size).to be 1

        parent = instance.parent_resources.first
        expect(parent).to be_a described_class

        expect(parent.resource_class).to be Spec::Book
        expect(parent.resource_name).to be == 'book'
        expect(parent.resources_path).to be == '/books'
        expect(parent.index_template).to be == 'books/index'
      end # it
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:book) { Spec::Book.new }

      it 'should return the parent and grandparent resources',
        :aggregate_failures \
      do
        expect(instance.parent_resources).to be_a Array
        expect(instance.parent_resources.size).to be 2

        grandparent = instance.parent_resources.first
        expect(grandparent).to be_a described_class

        expect(grandparent.resource_class).to be Spec::Book
        expect(grandparent.resource_name).to be == 'book'
        expect(grandparent.resources_path).to be == '/books'
        expect(grandparent.index_template).to be == 'books/index'

        parent = instance.parent_resources.last
        expect(parent).to be_a described_class

        expect(parent.resource_class).to be Spec::Chapter
        expect(parent.resource_name).to be == 'chapter'
        expect(parent.resources_path book).
          to be == "/books/#{book.id}/chapters"
        expect(parent.index_template).to be == 'chapters/index'
        expect(parent.parent_resources).to be == [grandparent]
      end # it
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' do
      it 'should return the parent resource', :aggregate_failures do
        expect(instance.parent_resources).to be_a Array
        expect(instance.parent_resources.size).to be 1

        parent = instance.parent_resources.first
        expect(parent).to be_a described_class

        expect(parent.resource_class).to be Spec::Book
        expect(parent.resource_name).to be == 'book'
        expect(parent.resources_path).to be == '/admin/books'
        expect(parent.index_template).to be == 'admin/books/index'
      end # it
    end # wrap_context
  end # describe

  describe '#primary_key' do
    include_examples 'should have reader', :primary_key, :book_id

    context 'when options[:primary_key] is set' do
      let(:resource_options) { super().merge :primary_key => :tome_id }

      it { expect(instance.primary_key).to be :tome_id }
    end # context
  end # describe

  describe '#singular_association_key' do
    include_examples 'should have reader',
      :singular_association_key,
      ->() { be == :book }

    it 'should alias the method' do
      expect(instance).
        to alias_method(:singular_association_key).
        as(:parent_key)
    end # it

    context 'when options[:association_name] is set' do
      let(:resource_options) { super().merge :association_name => 'tomes' }

      it { expect(instance.singular_association_key).to be == :tome }
    end # context
  end # describe

  describe '#singular_association_name' do
    include_examples 'should have reader',
      :singular_association_name,
      ->() { be == 'book' }

    it 'should alias the method' do
      expect(instance).
        to alias_method(:singular_association_name).
        as(:parent_name)
    end # it

    context 'when options[:association_name] is set' do
      let(:resource_options) { super().merge :association_name => 'tomes' }

      it { expect(instance.singular_association_name).to be == 'tome' }
    end # context
  end # describe
end # describe
