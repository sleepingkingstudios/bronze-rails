# spec/bronze/rails/resources/resource/routing_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/resources/resource/routing'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::Resource::Routing do
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

  describe '#edit_resource_path' do
    let(:object)   { resource_class.new }
    let(:expected) { "/books/#{object.id}/edit" }

    it 'should define the method' do
      expect(instance).
        to respond_to(:edit_resource_path).
        with(1).argument.
        and_unlimited_arguments
    end # it

    describe 'with the resource' do
      it { expect(instance.edit_resource_path object).to be == expected }
    end # describe

    describe 'with the resource id' do
      it 'should generate the url' do
        expect(instance.edit_resource_path object.id).to be == expected
      end # it
    end # describe

    wrap_context 'when the resource has many namespaces' do
      let(:expected) { "/admin/api/books/#{object.id}/edit" }

      describe 'with the resource' do
        it 'should generate the url' do
          expect(instance.edit_resource_path object).to be == expected
        end # it
      end # describe

      describe 'with the resource id' do
        it 'should generate the url' do
          expect(instance.edit_resource_path object.id).to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      let(:expected) do
        "/admin/books/#{book.id}/chapters/#{object.id}/edit"
      end # let

      describe 'with the parent resource id and resource id' do
        it 'should generate the url' do
          expect(instance.edit_resource_path book.id, object.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resource and resource' do
        it 'should generate the url' do
          expect(instance.edit_resource_path book, object).
            to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections/#{object.id}" \
        '/edit'
      end # let

      describe 'with the parent resource ids and resource id' do
        it 'should generate the url' do
          expect(
            instance.edit_resource_path book.id, chapter.id, object.id
          ). # end expect
            to be == expected
        end # it
      end # describe

      describe 'with the parent resources and resource id' do
        it 'should generate the url' do
          expect(instance.edit_resource_path book, chapter, object).
            to be == expected
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#namespaces' do
    include_examples 'should have reader', :namespaces, []

    wrap_context 'when the resource has many namespaces' do
      it { expect(instance.namespaces).to be == resource.namespaces }
    end # include_examples

    wrap_context 'when the resource has a namespace and a parent resource' do
      it { expect(instance.namespaces).to be == resource.namespaces }
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      it { expect(instance.namespaces).to be == resource.namespaces }
    end # wrap_context
  end # describe

  describe '#new_resource_path' do
    let(:expected) { '/books/new' }

    it 'should define the method' do
      expect(instance).
        to respond_to(:new_resource_path).
        with_unlimited_arguments
    end # it

    it { expect(instance.new_resource_path).to be == expected }

    wrap_context 'when the resource has many namespaces' do
      let(:expected) { '/admin/api/books/new' }

      it { expect(instance.new_resource_path).to be == expected }
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      let(:expected) { "/admin/books/#{book.id}/chapters/new" }

      describe 'with the parent resource id' do
        it 'should generate the url' do
          expect(instance.new_resource_path book.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resource' do
        it 'should generate the url' do
          expect(instance.new_resource_path book).
            to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections/new"
      end # let

      describe 'with the parent resource ids' do
        it 'should generate the url' do
          expect(instance.new_resource_path book.id, chapter.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resources' do
        it 'should generate the url' do
          expect(instance.new_resource_path book, chapter).
            to be == expected
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#parent_resources_path' do
    let(:expected) { '/' }

    it 'should define the method' do
      expect(instance).
        to respond_to(:parent_resources_path).
        with_unlimited_arguments
    end # it

    it { expect(instance.parent_resources_path).to be == expected }

    wrap_context 'when the resource has many namespaces' do
      it { expect(instance.parent_resources_path).to be == expected }
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      let(:expected) { '/admin/books' }

      it { expect(instance.parent_resources_path).to be == expected }
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:expected) do
        "/books/#{book.id}/chapters"
      end # let

      describe 'with the parent resource id' do
        it { expect(instance.parent_resources_path book.id).to be == expected }
      end # describe

      describe 'with the parent resource' do
        it { expect(instance.parent_resources_path book).to be == expected }
      end # describe
    end # wrap_context
  end # describe

  describe '#resource' do
    include_examples 'should have reader', :resource, ->() { resource }
  end # describe

  describe '#resource_path' do
    let(:object)   { resource_class.new }
    let(:expected) { "/books/#{object.id}" }

    it 'should define the method' do
      expect(instance).
        to respond_to(:resource_path).
        with(1).argument.
        and_unlimited_arguments
    end # it

    describe 'with the resource' do
      it { expect(instance.resource_path object).to be == expected }
    end # describe

    describe 'with the resource id' do
      it { expect(instance.resource_path object.id).to be == expected }
    end # describe

    wrap_context 'when the resource has many namespaces' do
      let(:expected) { "/admin/api/books/#{object.id}" }

      describe 'with the resource' do
        it { expect(instance.resource_path object).to be == expected }
      end # describe

      describe 'with the resource id' do
        it { expect(instance.resource_path object.id).to be == expected }
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      let(:expected) { "/admin/books/#{book.id}/chapters/#{object.id}" }

      describe 'with the parent resource id and resource id' do
        it 'should generate the url' do
          expect(instance.resource_path book.id, object.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resource and resource' do
        it 'should generate the url' do
          expect(instance.resource_path book, object).
            to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections/#{object.id}"
      end # let

      describe 'with the parent resource ids and resource id' do
        it 'should generate the url' do
          expect(instance.resource_path book.id, chapter.id, object.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resources and resource id' do
        it 'should generate the url' do
          expect(instance.resource_path book, chapter, object).
            to be == expected
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#resources_path' do
    let(:expected) { '/books' }

    it 'should define the method' do
      expect(instance).
        to respond_to(:resources_path).
        with_unlimited_arguments
    end # it

    it { expect(instance.resources_path).to be == expected }

    wrap_context 'when the resource has many namespaces' do
      let(:expected) { '/admin/api/books' }

      it { expect(instance.resources_path).to be == expected }
    end # wrap_context

    wrap_context 'when the resource has a namespace and a parent resource' \
    do
      let(:expected) { "/admin/books/#{book.id}/chapters" }

      describe 'with the parent resource id' do
        it 'should generate the url' do
          expect(instance.resources_path book.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resource' do
        it 'should generate the url' do
          expect(instance.resources_path book).
            to be == expected
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has many parent resources' do
      let(:expected) do
        "/books/#{book.id}/chapters/#{chapter.id}/sections"
      end # let

      describe 'with the parent resource ids' do
        it 'should generate the url' do
          expect(instance.resources_path book.id, chapter.id).
            to be == expected
        end # it
      end # describe

      describe 'with the parent resources' do
        it 'should generate the url' do
          expect(instance.resources_path book, chapter).
            to be == expected
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
