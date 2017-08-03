# spec/bronze/rails/resources/resource/templates_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/rails/resources/resource/base_examples'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module TemplatesExamples
    extend  RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    include Spec::Resources::Resource::BaseExamples

    shared_examples 'should implement the Resource::Templates methods' do
      describe '#controller_name' do
        include_examples 'should have reader',
          :controller_name,
          ->() { be == 'books' }

        context 'when options[:controller_name] is a class name' do
          let(:resource_options) do
            super().merge :controller_name => 'TomesController'
          end # let

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context

        context 'when options[:controller_name] is a string' do
          let(:resource_options) do
            super().merge :controller_name => 'tomes'
          end # let

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context

        context 'when options[:controller_name] is a symbol' do
          let(:resource_options) do
            super().merge :controller_name => :tomes
          end # let

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => :tomes }

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => :tome }

          it { expect(instance.controller_name).to be == 'tomes' }
        end # context
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

        context 'when options[:controller_name] is set' do
          let(:resource_options) do
            super().merge :controller_name => 'TomesController'
          end # let
          let(:expected) { 'tomes/read' }

          it { expect(instance.template action_name).to be == expected }
        end # context

        context 'when options[:plural_resource_name] is set' do
          let(:resource_options) do
            super().merge :plural_resource_name => 'tomes'
          end # let
          let(:expected) { 'tomes/read' }

          it { expect(instance.template action_name).to be == expected }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) do
            super().merge :resource_name => 'tome'
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
    end # shared_examples
  end # module
end # module
