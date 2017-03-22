# spec/bronze/rails/responders/render_view_responder_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource'
require 'bronze/rails/responders/render_view_responder'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

RSpec.describe Bronze::Rails::Responders::RenderViewResponder do
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

  let(:render_context) do
    double('render_context', :render => nil, :redirect_to => nil)
  end # let
  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_definition) do
    Bronze::Rails::Resources::Resource.new resource_class, resource_options
  end # let
  let(:resources)        { {} }
  let(:instance_options) { { :resources => resources } }
  let(:instance) do
    described_class.new render_context, resource_definition, instance_options
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '#build_resources_hash' do
    let(:operation) do
      double(
        'operation',
        :resource  => double('resource'),
        :resources => Array.new(3) { double('resource') }
      ) # end operation
    end # let

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_resources_hash)

      expect(instance).
        to respond_to(:build_resources_hash, true).
        with(1).argument.
        and_keywords(:many)
    end # it

    it 'should wrap the resource' do
      expect(instance.send :build_resources_hash, operation).
        to be == { :book => operation.resource }
    end # it

    describe 'with :many => false' do
      it 'should wrap the resource' do
        expect(instance.send :build_resources_hash, operation, :many => false).
          to be == { :book => operation.resource }
      end # it
    end # describe

    describe 'with :many => true' do
      it 'should wrap the resources' do
        expect(instance.send :build_resources_hash, operation, :many => true).
          to be == { :books => operation.resources }
      end # it
    end # describe

    wrap_context 'when the resource has a parent resource' do
      let(:book)      { Spec::Book.new }
      let(:resources) { super().merge :book => book }

      it 'should wrap the resource and parent' do
        expect(instance.send :build_resources_hash, operation).
          to be == {
            :book    => book,
            :chapter => operation.resource
          } # end resources
      end # it

      describe 'with :many => false' do
        it 'should wrap the resource and parent' do
          expect(instance.send :build_resources_hash, operation).
            to be == {
              :book    => book,
              :chapter => operation.resource
            } # end resources
        end # it
      end # describe

      describe 'with :many => true' do
        it 'should wrap the resources and parent' do
          expect(instance.send :build_resources_hash, operation, :many => true).
            to be == {
              :book     => book,
              :chapters => operation.resources
            } # end resources
        end # it
      end # describe
    end # wrap_context

    wrap_context 'when the resource has a grandparent and parent resource' do
      let(:book)      { Spec::Book.new }
      let(:chapter)   { Spec::Chapter.new }
      let(:resources) { super().merge :book => book, :chapter => chapter }

      it 'should wrap the resource and ancestors' do
        expect(instance.send :build_resources_hash, operation).
          to be == {
            :book    => book,
            :chapter => chapter,
            :section => operation.resource
          } # end resources
      end # it

      describe 'with :many => false' do
        it 'should wrap the resource and parent' do
          expect(instance.send :build_resources_hash, operation).
            to be == {
              :book    => book,
              :chapter => chapter,
              :section => operation.resource
            } # end resources
        end # it
      end # describe

      describe 'with :many => true' do
        it 'should wrap the resources and parent' do
          expect(instance.send :build_resources_hash, operation, :many => true).
            to be == {
              :book    => book,
              :chapter  => chapter,
              :sections => operation.resources
            } # end resources
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#call' do
    shared_examples 'should redirect to' do |redirect_path, *args|
      block = args.pop if args.last.is_a?(Proc)
      opts  = args.last.is_a?(Hash) ? args.pop : {}

      example_description =
        "should redirect to #{opts.fetch :as, redirect_path}"

      it example_description do
        allow(render_context).to receive(:redirect_to)
        allow(render_context).to receive(:render)

        perform_action

        expected_path =
          if redirect_path.is_a?(Proc)
            redirect_path = instance_exec(&redirect_path)
          else
            # :nocov:
            redirect_path
            # :nocov:
          end # if-else

        expect(render_context).not_to have_received(:render)

        expect(render_context).to have_received(:redirect_to) { |path|
          expect(path).to be == expected_path

          instance_exec(&block) if block.is_a?(Proc)
        } # end redirect_to options
      end # it
    end # shared_examples

    shared_examples 'should render template' do |template, *args|
      block = args.pop if args.last.is_a?(Proc)
      _opts = args.last.is_a?(Hash) ? args.pop : {}

      example_description =
        "should render template #{template}"

      it example_description do
        allow(render_context).to receive(:redirect_to)
        allow(render_context).to receive(:render)

        perform_action

        expect(render_context).to have_received(:render) { |options|
          expect(options[:template]).to be == template

          instance_exec(options, &block) if block.is_a?(Proc)
        } # end render options
      end # it
    end # shared_examples

    let(:errors)  { double('errors') }
    let(:action)  { nil }
    let(:success) { false }
    let(:operation) do
      double(
        'operation',
        :resource  => double('resource'),
        :resources => Array.new(3) { double('resource') },
        :errors    => errors,
        :success?  => success
      ) # end operation
    end # let

    def perform_action
      instance.call(operation, :action => action)
    end # method perform_action

    it 'should define the method' do
      expect(instance).
        to respond_to(:call).
        with(0..1).arguments.
        and_keywords(:action)
    end # it

    describe 'with :action => "not_found"' do
      let(:action)    { :not_found }
      let(:operation) { nil }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
        :as => 'resources path'
    end # describe

    describe 'with :action => :create and a failing operation' do
      let(:action) { :create }

      include_examples 'should render template',
        'books/new',
        lambda { |options|
          expect(options[:status]).to be :unprocessable_entity
          expect(options[:locals]).
            to be == {
              :book        => operation.resource,
              :errors      => operation.errors,
              :form_action => instance.send(:resources_path),
              :form_method => :post
            } # end locals
        } # end lambda
    end # describe

    describe 'with :action => :create and a passing operation' do
      let(:action)  { :create }
      let(:success) { true }

      include_examples 'should redirect to',
        ->() { resource_definition.resource_path operation.resource },
        :as => 'resource path'
    end # describe

    describe 'with :action => :destroy and a failing operation' do
      let(:action) { :destroy }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
        :as => 'resources path'
    end # describe

    describe 'with :action => :destroy and a passing operation' do
      let(:action)  { :destroy }
      let(:success) { true }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
        :as => 'resources path'
    end # describe

    describe 'with :action => :edit and a failing operation' do
      let(:action) { :edit }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
        :as => 'resources path'
    end # describe

    describe 'with :action => :edit and a passing operation' do
      let(:action)  { :edit }
      let(:success) { true }

      include_examples 'should render template',
        'books/edit',
        lambda { |options|
          expect(options[:status]).to be :ok
          expect(options[:locals]).
            to be == {
              :book        => operation.resource,
              :errors      => [],
              :form_action => instance.send(:resource_path, operation.resource),
              :form_method => :patch
            } # end locals
        } # end lambda
    end # describe

    describe 'with :action => :index and a failing operation' do
      let(:action) { :index }

      include_examples 'should redirect to',
        ->() { Bronze::Rails::Services::RoutesService.instance.root_path },
        :as => 'root path'

      wrap_context 'when the resource has a parent resource' do
        let(:parent) { resource_definition.parent_resources.last }

        include_examples 'should redirect to',
          ->() { parent.resources_path },
          :as => 'parent resources path'
      end # wrap_context

      wrap_context 'when the resource has a grandparent and parent resource' do
        let(:book)      { Spec::Book.new }
        let(:parent)    { resource_definition.parent_resources.last }
        let(:resources) { { :book => book } }

        include_examples 'should redirect to',
          ->() { parent.resources_path(book) },
          :as => 'parent resources path'
      end # wrap_context
    end # describe

    describe 'with :action => :index and a passing operation' do
      let(:action)  { :index }
      let(:success) { true }

      include_examples 'should render template',
        'books/index',
        lambda { |options|
          expect(options[:status]).to be :ok
          expect(options[:locals]).
            to be == { :books => operation.resources }
        } # end lambda
    end # describe

    describe 'with :action => :new and a failing operation' do
      let(:action) { :new }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
        :as => 'resources path'
    end # describe

    describe 'with :action => :new and a passing operation' do
      let(:action)  { :new }
      let(:success) { true }

      include_examples 'should render template',
        'books/new',
        lambda { |options|
          expect(options[:status]).to be :ok
          expect(options[:locals]).
            to be == {
              :book        => operation.resource,
              :errors      => [],
              :form_action => instance.send(:resources_path),
              :form_method => :post
            } # end locals
        } # end lambda
    end # describe

    describe 'with :action => :show and a failing operation' do
      let(:action) { :show }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
        :as => 'resources path'
    end # describe

    describe 'with :action => :show and a passing operation' do
      let(:action)  { :show }
      let(:success) { true }

      include_examples 'should render template',
        'books/show',
        lambda { |options|
          expect(options[:status]).to be :ok
          expect(options[:locals]).
            to be == { :book => operation.resource }
        } # end lambda
    end # describe

    describe 'with :action => :update and a failing operation' do
      let(:action) { :update }

      include_examples 'should render template',
        'books/edit',
        lambda { |options|
          expect(options[:status]).to be :unprocessable_entity
          expect(options[:locals]).
            to be == {
              :book        => operation.resource,
              :errors      => operation.errors,
              :form_action => instance.send(:resource_path, operation.resource),
              :form_method => :patch
            } # end locals
        } # end lambda
    end # describe

    describe 'with :action => :update and a passing operation' do
      let(:action)  { :update }
      let(:success) { true }

      include_examples 'should redirect to',
        ->() { resource_definition.resource_path(operation.resource) },
        :as => 'resource path'
    end # describe
  end # describe

  describe '#render_context' do
    include_examples 'should have reader',
      :render_context,
      ->() { be == render_context }
  end # describe

  describe '#resource_definition' do
    include_examples 'should have reader',
      :resource_definition,
      ->() { be == resource_definition }
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
