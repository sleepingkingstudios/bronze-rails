# spec/bronze/rails/responders/render_view_responder_spec.rb

require 'rails_helper'

require 'bronze/rails/resources/resource_routing'
require 'bronze/rails/responders/render_view_responder'
require 'bronze/rails/responders/responder_examples'

require 'support/mocks/controller'

RSpec.describe Bronze::Rails::Responders::RenderViewResponder do
  include Spec::Examples::ResponderExamples

  let(:render_context)   { Spec::Controller.new }
  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_definition) do
    Bronze::Rails::Resources::Resource.new resource_class, resource_options
  end # let
  let(:resource_routing) do
    Bronze::Rails::Resources::ResourceRouting.new(resource_definition)
  end # let
  let(:resources)        { {} }
  let(:instance_options) { { :resources => resources } }
  let(:instance) do
    described_class.new render_context, resource_definition, instance_options
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  include_examples 'should implement the Responder methods'

  describe '#build_resources_hash' do
    let(:result)    { double('resource') }
    let(:operation) { double('operation', :result => result) }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_resources_hash)

      expect(instance).
        to respond_to(:build_resources_hash, true).
        with(1).argument.
        and_keywords(:many)
    end # it

    it 'should wrap the resource' do
      expect(instance.send :build_resources_hash, operation).
        to be == { :book => operation.result }
    end # it

    describe 'with :many => false' do
      it 'should wrap the resource' do
        expect(instance.send :build_resources_hash, operation, :many => false).
          to be == { :book => operation.result }
      end # it
    end # describe

    describe 'with :many => true' do
      it 'should wrap the resources' do
        expect(instance.send :build_resources_hash, operation, :many => true).
          to be == { :books => operation.result }
      end # it
    end # describe

    wrap_context 'when the resource has a parent resource' do
      let(:book)      { Spec::Book.new }
      let(:resources) { super().merge :book => book }

      it 'should wrap the resource and parent' do
        expect(instance.send :build_resources_hash, operation).
          to be == {
            :book    => book,
            :chapter => operation.result
          } # end resources
      end # it

      describe 'with :many => false' do
        it 'should wrap the resource and parent' do
          expect(instance.send :build_resources_hash, operation).
            to be == {
              :book    => book,
              :chapter => operation.result
            } # end resources
        end # it
      end # describe

      describe 'with :many => true' do
        it 'should wrap the resources and parent' do
          expect(instance.send :build_resources_hash, operation, :many => true).
            to be == {
              :book     => book,
              :chapters => operation.result
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
            :section => operation.result
          } # end resources
      end # it

      describe 'with :many => false' do
        it 'should wrap the resource and parent' do
          expect(instance.send :build_resources_hash, operation).
            to be == {
              :book    => book,
              :chapter => chapter,
              :section => operation.result
            } # end resources
        end # it
      end # describe

      describe 'with :many => true' do
        it 'should wrap the resources and parent' do
          expect(instance.send :build_resources_hash, operation, :many => true).
            to be == {
              :book    => book,
              :chapter  => chapter,
              :sections => operation.result
            } # end resources
        end # it
      end # describe
    end # wrap_context

    describe 'when options[:resource_names] is set' do
      let(:resource_names) { [:author, :chapters] }
      let(:resources) do
        super().
          merge(
            :author   => double('author'),
            :chapters => Array.new(3) { Spec::Chapter.new }
          ) # end merge
      end # let
      let(:instance_options) do
        super().merge :resource_names => resource_names
      end # let

      it 'should wrap the resource' do
        expect(instance.send :build_resources_hash, operation).
          to be == {
            :author   => resources[:author],
            :chapters => resources[:chapters],
            :book     => operation.result
          } # end resources
      end # it

      describe 'with :many => false' do
        it 'should wrap the resource' do
          expect(instance.send :build_resources_hash, operation).
            to be == {
              :author   => resources[:author],
              :chapters => resources[:chapters],
              :book     => operation.result
            } # end resources
        end # it
      end # describe

      describe 'with :many => true' do
        it 'should wrap the resources' do
          expect(instance.send :build_resources_hash, operation, :many => true).
            to be == {
              :author   => resources[:author],
              :chapters => resources[:chapters],
              :books    => operation.result
            } # end resources
        end # it
      end # describe
    end # describe
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

    let(:errors)  { Bronze::Errors.new }
    let(:action)  { nil }
    let(:success) { false }
    let(:result)  { double('resource') }
    let(:operation) do
      double(
        'operation',
        :result   => result,
        :errors   => errors,
        :success? => success
      ) # end operation
    end # let
    let(:error_messages) do
      double('error messages')
    end # let
    let(:message) do
      'This is a test of the emergency broadcast system. This is only a test.'
    end # let

    before(:example) do
      allow(instance).
        to receive(:build_error_messages).
        with(errors).
        and_return(error_messages)

      allow(instance).
        to receive(:build_message).
        with(action, success ? :success : :failure).
        and_return(message)
    end # before example

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

      before(:example) do
        allow(instance).
          to receive(:build_message).
          with(action).
          and_return(message)
      end # before example

      include_examples 'should redirect to',
        ->() { resource_routing.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:warning]).to include message
      end # it
    end # describe

    describe 'with :action => :create and a failing operation' do
      let(:action) { :create }

      include_examples 'should render template',
        'books/new',
        lambda { |options|
          expect(options[:status]).to be :unprocessable_entity
          expect(options[:locals]).
            to be == {
              :book        => operation.result,
              :errors      => error_messages,
              :form_action => instance.send(:resources_path),
              :form_method => :post
            } # end locals
        } # end lambda

      it 'should set the flash' do
        perform_action

        expect(render_context.flash.now[:warning]).to include message
      end # it
    end # describe

    describe 'with :action => :create and a passing operation' do
      let(:action)  { :create }
      let(:success) { true }

      include_examples 'should redirect to',
        ->() { resource_routing.resource_path operation.result },
        :as => 'resource path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:success]).to include message
      end # it
    end # describe

    describe 'with :action => :destroy and a failing operation' do
      let(:action) { :destroy }

      include_examples 'should redirect to',
        ->() { resource_routing.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:warning]).to include message
      end # it
    end # describe

    describe 'with :action => :destroy and a passing operation' do
      let(:action)  { :destroy }
      let(:success) { true }

      include_examples 'should redirect to',
        ->() { resource_routing.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:danger]).to include message
      end # it
    end # describe

    describe 'with :action => :edit and a failing operation' do
      let(:action) { :edit }

      include_examples 'should redirect to',
        ->() { resource_routing.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:warning]).to include message
      end # it
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
              :book        => operation.result,
              :errors      => [],
              :form_action => instance.send(:resource_path, operation.result),
              :form_method => :patch
            } # end locals
        } # end lambda

      it 'should not set the flash' do
        perform_action

        expect(render_context.flash).to be_empty
      end # it
    end # describe

    describe 'with :action => :index and a failing operation' do
      let(:action) { :index }

      include_examples 'should redirect to',
        ->() { Bronze::Rails::Services::RoutesService.instance.root_path },
        :as => 'root path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:warning]).to include message
      end # it

      wrap_context 'when the resource has a parent resource' do
        let(:parent) { resource_definition.parent_resources.last }
        let(:parent_routing) do
          Bronze::Rails::Resources::ResourceRouting.new(parent)
        end # let

        include_examples 'should redirect to',
          ->() { parent_routing.resources_path },
          :as => 'parent resources path'
      end # wrap_context

      wrap_context 'when the resource has a grandparent and parent resource' do
        let(:book)      { Spec::Book.new }
        let(:parent)    { resource_definition.parent_resources.last }
        let(:resources) { { :book => book } }
        let(:parent_routing) do
          Bronze::Rails::Resources::ResourceRouting.new(parent)
        end # let

        include_examples 'should redirect to',
          ->() { parent_routing.resources_path(book) },
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
            to be == { :books => operation.result }
        } # end lambda

      it 'should not set the flash' do
        perform_action

        expect(render_context.flash).to be_empty
      end # it
    end # describe

    describe 'with :action => :new and a failing operation' do
      let(:action) { :new }

      include_examples 'should redirect to',
        ->() { resource_routing.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:warning]).to include message
      end # it
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
              :book        => operation.result,
              :errors      => [],
              :form_action => instance.send(:resources_path),
              :form_method => :post
            } # end locals
        } # end lambda

      it 'should not set the flash' do
        perform_action

        expect(render_context.flash).to be_empty
      end # it
    end # describe

    describe 'with :action => :show and a failing operation' do
      let(:action) { :show }

      include_examples 'should redirect to',
        ->() { resource_routing.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:warning]).to include message
      end # it
    end # describe

    describe 'with :action => :show and a passing operation' do
      let(:action)  { :show }
      let(:success) { true }

      include_examples 'should render template',
        'books/show',
        lambda { |options|
          expect(options[:status]).to be :ok
          expect(options[:locals]).
            to be == { :book => operation.result }
        } # end lambda

      it 'should not set the flash' do
        perform_action

        expect(render_context.flash).to be_empty
      end # it
    end # describe

    describe 'with :action => :update and a failing operation' do
      let(:action) { :update }

      include_examples 'should render template',
        'books/edit',
        lambda { |options|
          expect(options[:status]).to be :unprocessable_entity
          expect(options[:locals]).
            to be == {
              :book        => operation.result,
              :errors      => error_messages,
              :form_action => instance.send(:resource_path, operation.result),
              :form_method => :patch
            } # end locals
        } # end lambda

      it 'should set the flash' do
        perform_action

        expect(render_context.flash.now[:warning]).to include message
      end # it
    end # describe

    describe 'with :action => :update and a passing operation' do
      let(:action)  { :update }
      let(:success) { true }

      include_examples 'should redirect to',
        ->() { resource_routing.resource_path(operation.result) },
        :as => 'resource path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:success]).to include message
      end # it
    end # describe
  end # describe

  describe '#render_context' do
    include_examples 'should have reader',
      :render_context,
      ->() { be == render_context }
  end # describe
end # describe
