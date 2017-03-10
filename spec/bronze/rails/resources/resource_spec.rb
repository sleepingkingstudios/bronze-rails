# spec/bronze/rails/resources/resource_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'

require 'fixtures/entities/archived_periodical'
require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource do
  shared_context 'when the resource class has a compound name' do
    let(:resource_class) { Spec::ArchivedPeriodical }
  end # shared_context

  shared_context 'when the resource has a namespace' do
    let(:ancestors) do
      [
        {
          :name => :admin,
          :type => :namespace
        } # end admin
      ] # end ancestors
    end # let
    let(:resource_options) do
      super().merge :ancestors => ancestors
    end # let
  end # shared_context

  shared_context 'when the resource has a compound namespace' do
    let(:ancestors) do
      [
        {
          :name => :admin,
          :type => :namespace
        }, # end admin
        {
          :name => :api,
          :type => :namespace
        } # end api
      ] # end ancestors
    end # let
    let(:resource_options) do
      super().merge :ancestors => ancestors
    end # let
  end # shared_context

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

  shared_context 'when the resource has a grandparent and parent resource' do
    let(:ancestors) do
      [
        {
          :name  => :books,
          :type  => :resource,
          :class => Spec::Book
        }, # end books
        {
          :name  => :chapters,
          :type  => :resource,
          :class => Spec::Chapter
        } # end chapters
      ] # end ancestors
    end # let
    let(:resource_class) { Spec::Section }
    let(:resource_options) do
      super().merge :ancestors => ancestors
    end # let
  end # shared_context

  shared_context 'when the resource has a namespace and a parent resource' do
    let(:ancestors) do
      [
        {
          :name => :admin,
          :type => :namespace
        }, # end admin
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

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

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

  describe '#find_parent_resource' do
    it 'should define the method' do
      expect(instance).to respond_to(:find_parent_resource).with(1).argument
    end # it

    it { expect(instance.find_parent_resource :books).to be nil }

    wrap_context 'when the resource has a parent resource' do
      let(:expected) { instance.parent_resources.first }

      it 'should find the resource' do
        expect(instance.find_parent_resource :books).to be expected
      end # it

      context 'when the parent has options[:association_name] set' do
        let(:ancestors) do
          super().tap do |ary|
            ary.first[:association_name] = 'tome'
          end # tap
        end # let

        it 'should find the resource' do
          expect(instance.find_parent_resource :books).to be expected
        end # it

        it 'should find the resource' do
          expect(instance.find_parent_resource :tome).to be expected
        end # it
      end # context
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      let(:grandparent) { instance.parent_resources.first }
      let(:parent)      { instance.parent_resources.last }

      it 'should find the grandparent resource' do
        expect(instance.find_parent_resource :books).to be grandparent
      end # it

      it 'should find the parent resource' do
        expect(instance.find_parent_resource :chapters).to be parent
      end # it
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' do
      let(:expected) { instance.parent_resources.first }

      it 'should find the resource' do
        expect(instance.find_parent_resource :books).to be expected
      end # it
    end # wrap_context
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

    wrap_context 'when the resource has a grandparent and parent resource' do
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

  describe '#plural_resource_key' do
    include_examples 'should have reader', :plural_resource_key, :books

    context 'when options[:resource_key] is set' do
      let(:resource_options) { super().merge :resource_key => :tome }

      it { expect(instance.plural_resource_key).to be == :tomes }
    end # context

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

  describe '#primary_key' do
    include_examples 'should have reader', :primary_key, :book_id

    context 'when options[:primary_key] is set' do
      let(:resource_options) { super().merge :primary_key => :tome_id }

      it { expect(instance.primary_key).to be :tome_id }
    end # context
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

    context 'when options[:resource_key] is set' do
      let(:resource_options) { super().merge :resource_key => :tome }

      it { expect(instance.resource_key).to be == :tome }
    end # context

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

    context 'when options[:association_name] is a plural string' do
      let(:resource_options) { super().merge :resource_name => 'tomes' }

      it { expect(instance.resource_name).to be == 'tome' }
    end # context

    context 'when options[:association_name] is a plural symbol' do
      let(:resource_options) { super().merge :resource_name => :tomes }

      it { expect(instance.resource_name).to be == 'tome' }
    end # context

    context 'when options[:association_name] is a singular string' do
      let(:resource_options) { super().merge :resource_name => 'tome' }

      it { expect(instance.resource_name).to be == 'tome' }
    end # context

    context 'when options[:association_name] is a singular symbol' do
      let(:resource_options) { super().merge :resource_name => :tome }

      it { expect(instance.resource_name).to be == 'tome' }
    end # context

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

    it 'should define the method' do
      expect(instance).
        to respond_to(:resource_path).
        with(1).arguments.
        and_unlimited_arguments
    end # it

    describe 'with a resource id' do
      it { expect(instance.resource_path book.id).to be == "/books/#{book.id}" }
    end # describe

    describe 'with a resource instance' do
      it { expect(instance.resource_path book).to be == "/books/#{book.id}" }
    end # describe

    wrap_context 'when the resource has a namespace' do
      describe 'with a resource id' do
        it 'should return the relative path' do
          expect(instance.resource_path book.id).
            to be == "/admin/books/#{book.id}"
        end # it
      end # describe

      describe 'with a resource instance' do
        it 'should return the relative path' do
          expect(instance.resource_path book).
            to be == "/admin/books/#{book.id}"
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a compound namespace' do
      describe 'with a resource id' do
        it 'should return the relative path' do
          expect(instance.resource_path book.id).
            to be == "/admin/api/books/#{book.id}"
        end # it
      end # describe

      describe 'with a resource instance' do
        it 'should return the relative path' do
          expect(instance.resource_path book).
            to be == "/admin/api/books/#{book.id}"
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a parent resource' do
      let(:chapter)  { Spec::Chapter.new }
      let(:expected) { "/books/#{book.id}/chapters/#{chapter.id}" }

      describe 'with a resource id' do
        it 'should return the relative path' do
          expect(instance.resource_path book, chapter.id).to be == expected
        end # it
      end # describe

      describe 'with a resource instance' do
        it 'should return the relative path' do
          expect(instance.resource_path book, chapter).to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      let(:chapter)  { Spec::Chapter.new }
      let(:section)  { Spec::Section.new }
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections/#{section.id}"
      end # let

      describe 'with a resource id' do
        it 'should return the relative path' do
          expect(instance.resource_path book, chapter, section.id).
            to be == expected
        end # it
      end # describe

      describe 'with a resource instance' do
        it 'should return the relative path' do
          expect(instance.resource_path book, chapter, section).
            to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' do
      let(:chapter)  { Spec::Chapter.new }
      let(:expected) { "/admin/books/#{book.id}/chapters/#{chapter.id}" }

      describe 'with a resource id' do
        it 'should return the relative path' do
          expect(instance.resource_path book, chapter.id).to be == expected
        end # it
      end # describe

      describe 'with a resource instance' do
        it 'should return the relative path' do
          expect(instance.resource_path book, chapter).to be == expected
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#resources_path' do
    it 'should define the method' do
      expect(instance).to respond_to(:resources_path).with_unlimited_arguments
    end # it

    it { expect(instance.resources_path).to be == '/books' }

    wrap_context 'when the resource has a namespace' do
      it { expect(instance.resources_path).to be == '/admin/books' }
    end # wrap_context

    wrap_context 'when the resource has a compound namespace' do
      it { expect(instance.resources_path).to be == '/admin/api/books' }
    end # wrap_context

    wrap_context 'when the resource has a parent resource' do
      let(:book)     { Spec::Book.new }
      let(:expected) { "/books/#{book.id}/chapters" }

      it 'should return the relative path' do
        expect(instance.resources_path book).to be == expected
      end # it
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      let(:book)     { Spec::Book.new }
      let(:chapter)  { Spec::Chapter.new }
      let(:expected) { "/books/#{book.id}/chapters/#{chapter.id}/sections" }

      it 'should return the relative path' do
        expect(instance.resources_path book, chapter).to be == expected
      end # it
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' do
      let(:book)     { Spec::Book.new }
      let(:expected) { "/admin/books/#{book.id}/chapters" }

      it 'should return the relative path' do
        expect(instance.resources_path book).to be == expected
      end # it
    end # wrap_context
  end # describe

  describe '#show_template' do
    include_examples 'should have reader',
      :show_template,
      ->() { be == 'books/show' }
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

  describe '#template' do
    it { expect(instance).to respond_to(:template).with(1).argument }

    describe 'with the name of an action' do
      let(:action) { 'defenestrate' }

      it { expect(instance.template action).to be == "books/#{action}" }
    end # describe

    wrap_context 'when the resource has a namespace' do
      describe 'with the name of an action' do
        let(:action) { 'defenestrate' }

        it { expect(instance.template action).to be == "admin/books/#{action}" }
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a compound namespace' do
      describe 'with the name of an action' do
        let(:action) { 'defenestrate' }

        it 'should return the template path' do
          expect(instance.template action).
            to be == "admin/api/books/#{action}"
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a parent resource' do
      describe 'with the name of an action' do
        let(:action) { 'defenestrate' }

        it { expect(instance.template action).to be == "chapters/#{action}" }
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      describe 'with the name of an action' do
        let(:action) { 'defenestrate' }

        it { expect(instance.template action).to be == "sections/#{action}" }
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' do
      describe 'with the name of an action' do
        let(:action) { 'defenestrate' }

        it 'should return the template path' do
          expect(instance.template action).to be == "admin/chapters/#{action}"
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
