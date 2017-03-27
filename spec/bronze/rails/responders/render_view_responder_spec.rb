# spec/bronze/rails/responders/render_view_responder_spec.rb

require 'rails_helper'

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
  let(:resources)        { {} }
  let(:instance_options) { { :resources => resources } }
  let(:instance) do
    described_class.new render_context, resource_definition, instance_options
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  include_examples 'should implement the Responder methods'

  describe '#build_errors' do
    shared_context 'with errors for one book' do
      before(:example) do
        expected_errors[:book].add(:banned, :reasons => [:subversive])
        expected_errors[:book][:title].add(:already_exists)
        expected_errors[:book][:author].add(:not_found)
      end # before example
    end # shared_context

    shared_context 'with errors for many books' do
      before(:example) do
        expected_errors[:books][0].add(:banned, :reasons => [:subversive])
        expected_errors[:books][1][:title].add(:already_exists)
        expected_errors[:books][2][:author].add(:not_found)
      end # before example
    end # shared_context

    let(:expected_errors) { Bronze::Errors.new }
    let(:operation)       { double('operation', :errors => expected_errors) }

    it 'should define the private method' do
      expect(instance).not_to respond_to(:build_errors)

      expect(instance).to respond_to(:build_errors, true).with(1).argument
    end # it

    it 'should return the errors' do
      expect(instance.send :build_errors, operation).to be == expected_errors
    end # it

    wrap_context 'with errors for one book' do
      it 'should return the errors' do
        expect(instance.send :build_errors, operation).to be == expected_errors
      end # it
    end # wrap_context

    wrap_context 'with errors for many books' do
      it 'should return the errors' do
        expect(instance.send :build_errors, operation).to be == expected_errors
      end # it
    end # wrap_context

    context 'when the resource key is overriden' do
      let(:resource_options) { super().merge :resource_key => :rare_book }

      it 'should return the errors' do
        expect(instance.send :build_errors, operation).to be == expected_errors
      end # it

      wrap_context 'with errors for one book' do
        it 'should return the errors with the configured key' do
          errors = instance.send :build_errors, operation

          expected_errors.each do |error|
            path    = error[:path]
            path[0] = resource_definition.resource_key

            expect(errors).to include(
              :type   => error[:type],
              :params => error[:params],
              :path   => path
            ) # end expect
          end # error
        end # it
      end # wrap_context

      wrap_context 'with errors for many books' do
        it 'should return the errors with the configured key' do
          errors = instance.send :build_errors, operation

          expected_errors.each do |error|
            path    = error[:path]
            path[0] = resource_definition.plural_resource_key

            expect(errors).to include(
              :type   => error[:type],
              :params => error[:params],
              :path   => path
            ) # end expect
          end # error
        end # it
      end # wrap_context
    end # context
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
            :book     => operation.resource
          } # end resources
      end # it

      describe 'with :many => false' do
        it 'should wrap the resource' do
          expect(instance.send :build_resources_hash, operation).
            to be == {
              :author   => resources[:author],
              :chapters => resources[:chapters],
              :book     => operation.resource
            } # end resources
        end # it
      end # describe

      describe 'with :many => true' do
        it 'should wrap the resources' do
          expect(instance.send :build_resources_hash, operation, :many => true).
            to be == {
              :author   => resources[:author],
              :chapters => resources[:chapters],
              :books    => operation.resources
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
    let(:message) do
      'This is a test of the emergency broadcast system. This is only a test.'
    end # let

    before(:example) do
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
        ->() { resource_definition.resources_path },
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
              :book        => operation.resource,
              :errors      => operation.errors,
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
        ->() { resource_definition.resource_path operation.resource },
        :as => 'resource path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:success]).to include message
      end # it
    end # describe

    describe 'with :action => :destroy and a failing operation' do
      let(:action) { :destroy }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
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
        ->() { resource_definition.resources_path },
        :as => 'resources path'

      it 'should set the flash' do
        perform_action

        expect(render_context.flash[:danger]).to include message
      end # it
    end # describe

    describe 'with :action => :edit and a failing operation' do
      let(:action) { :edit }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
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
              :book        => operation.resource,
              :errors      => [],
              :form_action => instance.send(:resource_path, operation.resource),
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

      it 'should not set the flash' do
        perform_action

        expect(render_context.flash).to be_empty
      end # it
    end # describe

    describe 'with :action => :new and a failing operation' do
      let(:action) { :new }

      include_examples 'should redirect to',
        ->() { resource_definition.resources_path },
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
              :book        => operation.resource,
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
        ->() { resource_definition.resources_path },
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
            to be == { :book => operation.resource }
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
              :book        => operation.resource,
              :errors      => operation.errors,
              :form_action => instance.send(:resource_path, operation.resource),
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
        ->() { resource_definition.resource_path(operation.resource) },
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
