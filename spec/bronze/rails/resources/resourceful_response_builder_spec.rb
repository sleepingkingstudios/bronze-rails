# spec/bronze/rails/resources/resourceful_response_builder_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resourceful_response_builder'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Resources::ResourcefulResponseBuilder do
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

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_definition) do
    Bronze::Rails::Resources::Resource.new resource_class, resource_options
  end # let
  let(:resources) { {} }
  let(:instance) do
    described_class.new resource_definition, resources
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  describe '#build_not_found_response' do
    let(:expected) { { :redirect_path => instance.send(:resources_path) } }

    it 'should define the method' do
      expect(instance).
        to respond_to(:build_not_found_response).
        with(0).arguments
    end # it

    it { expect(instance.build_not_found_response).to be == expected }
  end # describe

  describe '#build_response' do
    let(:errors) { double('errors') }
    let(:operation) do
      double(
        'operation',
        :resource  => double('resource'),
        :resources => Array.new(3) { double('resource') },
        :errors    => errors,
        :success?  => false
      ) # end operation
    end # let

    it 'should define the method' do
      expect(instance).
        to respond_to(:build_response).
        with(1).argument.
        and_keywords(:action)
    end # it

    describe 'with :action => :create and a failed operation' do
      let(:locals) do
        {
          :form_action => instance.send(:resources_path),
          :form_method => :post
        } # end locals
      end # let

      it 'should build the options' do
        options = instance.build_response operation, :action => :create

        expect(options[:http_status]).to be :unprocessable_entity
        expect(options[:errors]).to be errors
        expect(options[:template]).to be == 'books/new'
        expect(options[:resources]).to be == { :book => operation.resource }
        expect(options[:locals]).to be == locals
      end # it
    end # describe

    describe 'with :action => :create and a passed operation' do
      let(:expected) do
        { :redirect_path => instance.send(:resource_path, operation.resource) }
      end # let

      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        expect(instance.build_response operation, :action => :create).
          to be == expected
      end # it
    end # describe

    describe 'with :action => :destroy and a failed operation' do
      let(:expected) { { :redirect_path => instance.send(:resources_path) } }

      it 'should build the options' do
        expect(instance.build_response operation, :action => :destroy).
          to be == expected
      end # it
    end # describe

    describe 'with :action => :destroy and a passed operation' do
      let(:expected) { { :redirect_path => instance.send(:resources_path) } }

      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        expect(instance.build_response operation, :action => :destroy).
          to be == expected
      end # it
    end # describe

    describe 'with :action => :edit and a failed operation' do
      let(:expected) { { :redirect_path => instance.send(:resources_path) } }

      it 'should build the options' do
        expect(instance.build_response operation, :action => :edit).
          to be == expected
      end # it
    end # describe

    describe 'with :action => :edit and a passed operation' do
      let(:locals) do
        {
          :form_action => instance.send(:resource_path, operation.resource),
          :form_method => :patch
        } # end locals
      end # let

      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        options = instance.build_response operation, :action => :edit

        expect(options.key? :http_status).to be false
        expect(options[:errors]).to be == []
        expect(options[:template]).to be == 'books/edit'
        expect(options[:resources]).to be == { :book => operation.resource }
        expect(options[:locals]).to be == locals
      end # it
    end # describe

    describe 'with :action => :index and a failed operation' do
      let(:expected) { { :redirect_path => '/' } }

      it 'should build the options' do
        expect(instance.build_response operation, :action => :index).
          to be == expected
      end # it

      wrap_context 'when the resource has a parent resource' do
        let(:parent)   { resource_definition.parent_resources.last }
        let(:expected) { { :redirect_path => parent.resources_path } }

        it 'should build the options' do
          expect(instance.build_response operation, :action => :index).
            to be == expected
        end # it
      end # wrap_context

      wrap_context 'when the resource has a grandparent and parent resource' do
        let(:book)      { Spec::Book.new }
        let(:parent)    { resource_definition.parent_resources.last }
        let(:resources) { { :book => book } }
        let(:expected)  { { :redirect_path => parent.resources_path(book) } }

        it 'should build the options' do
          expect(instance.build_response operation, :action => :index).
            to be == expected
        end # it
      end # wrap_context
    end # describe

    describe 'with :action => :index and a passed operation' do
      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        options = instance.build_response operation, :action => :index

        expect(options.key? :http_status).to be false
        expect(options.key? :errors).to be false
        expect(options[:template]).to be == 'books/index'
        expect(options[:resources]).to be == { :books => operation.resources }
        expect(options.key? :locals).to be false
      end # it
    end # describe

    describe 'with :action => :new and a failed operation' do
      let(:expected) { { :redirect_path => instance.send(:resources_path) } }

      it 'should build the options' do
        expect(instance.build_response operation, :action => :new).
          to be == expected
      end # it
    end # describe

    describe 'with :action => :new and a passed operation' do
      let(:locals) do
        {
          :form_action => instance.send(:resources_path),
          :form_method => :post
        } # end locals
      end # let

      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        options = instance.build_response operation, :action => :new

        expect(options.key? :http_status).to be false
        expect(options[:errors]).to be == []
        expect(options[:template]).to be == 'books/new'
        expect(options[:resources]).to be == { :book => operation.resource }
        expect(options[:locals]).to be == locals
      end # it
    end # describe

    describe 'with :action => :show and a failed operation' do
      let(:expected) { { :redirect_path => instance.send(:resources_path) } }

      it 'should build the options' do
        expect(instance.build_response operation, :action => :show).
          to be == expected
      end # it
    end # describe

    describe 'with :action => :show and a passed operation' do
      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        options = instance.build_response operation, :action => :show

        expect(options.key? :http_status).to be false
        expect(options.key? :errors).to be false
        expect(options[:template]).to be == 'books/show'
        expect(options[:resources]).to be == { :book => operation.resource }
        expect(options.key? :locals).to be false
      end # it
    end # describe

    describe 'with :action => :update and a failed operation' do
      let(:locals) do
        {
          :form_action => instance.send(:resource_path, operation.resource),
          :form_method => :patch
        } # end locals
      end # let

      it 'should build the options' do
        options = instance.build_response operation, :action => :update

        expect(options[:http_status]).to be :unprocessable_entity
        expect(options[:errors]).to be errors
        expect(options[:template]).to be == 'books/edit'
        expect(options[:resources]).to be == { :book => operation.resource }
        expect(options[:locals]).to be == locals
      end # it
    end # describe

    describe 'with :action => :update and a passed operation' do
      let(:expected) do
        { :redirect_path => instance.send(:resource_path, operation.resource) }
      end # let

      before(:example) do
        allow(operation).to receive(:success?).and_return(true)
      end # before

      it 'should build the options' do
        expect(instance.build_response operation, :action => :update).
          to be == expected
      end # it
    end # describe
  end # describe

  describe '#resource_definition' do
    include_examples 'should have reader',
      :resource_definition,
      ->() { resource_definition }
  end # describe

  describe '#resource_path' do
    let(:book)     { Spec::Book.new }
    let(:expected) { "/books/#{book.id}" }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:resource_path)

      expect(instance).to respond_to(:resource_path, true).with(1).argument
    end # it

    it { expect(instance.send :resource_path, book).to be == expected }

    wrap_context 'when the resource has a parent resource' do
      let(:chapter) { Spec::Chapter.new }

      it 'should raise an error' do
        expect { instance.send :resource_path, chapter }.
          to raise_error ActionController::UrlGenerationError
      end # it

      context 'when resources includes the parent resources' do
        let(:resources) { super().merge :book => book }
        let(:expected)  { "/books/#{book.id}/chapters/#{chapter.id}" }

        it { expect(instance.send :resource_path, chapter).to be == expected }
      end # context
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      let(:section) { Spec::Section.new }

      it 'should raise an error' do
        expect { instance.send :resource_path, section }.
          to raise_error ActionController::UrlGenerationError
      end # it

      context 'when resources includes the parent resources' do
        let(:chapter)   { Spec::Chapter.new }
        let(:resources) { super().merge :book => book, :chapter => chapter }
        let(:expected) do
          "/books/#{book.id}/chapters/#{chapter.id}/sections/#{section.id}"
        end # let

        it { expect(instance.send :resource_path, section).to be == expected }
      end # context
    end # wrap_context
  end # describe

  describe '#resources_path' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:resources_path)

      expect(instance).to respond_to(:resources_path, true).with(0).arguments
    end # it

    it { expect(instance.send :resources_path).to be == '/books' }

    wrap_context 'when the resource has a parent resource' do
      it 'should raise an error' do
        expect { instance.send :resources_path }.
          to raise_error ActionController::UrlGenerationError
      end # it

      context 'when resources includes the parent resources' do
        let(:book)      { Spec::Book.new }
        let(:resources) { super().merge :book => book }
        let(:expected)  { "/books/#{book.id}/chapters" }

        it { expect(instance.send :resources_path).to be == expected }
      end # context
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      it 'should raise an error' do
        expect { instance.send :resources_path }.
          to raise_error ActionController::UrlGenerationError
      end # it

      context 'when resources includes the parent resources' do
        let(:book)      { Spec::Book.new }
        let(:chapter)   { Spec::Chapter.new }
        let(:resources) { super().merge :book => book, :chapter => chapter }
        let(:expected)  { "/books/#{book.id}/chapters/#{chapter.id}/sections" }

        it { expect(instance.send :resources_path).to be == expected }
      end # context
    end # wrap_context
  end # describe
end # describe
