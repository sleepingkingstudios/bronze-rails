# spec/bronze/rails/resources/resource/templates_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module TemplatesExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

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

      describe '#namespaces' do
        include_examples 'should have reader', :namespaces, []
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

        context 'when the resource has one namespace' do
          before(:example) do
            allow(instance).to receive(:namespaces).and_return(%i(admin))
          end # before example
          let(:expected) { 'admin/books/read' }

          it { expect(instance.template action_name).to be == expected }

          context 'when options[:controller_name] is set' do
            let(:resource_options) do
              super().merge :controller_name => 'TomesController'
            end # let
            let(:expected) { 'admin/tomes/read' }

            it { expect(instance.template action_name).to be == expected }
          end # context
        end # context

        context 'when the resource has many namespaces' do
          before(:example) do
            allow(instance).
              to receive(:namespaces).
              and_return(%i(admin publishers genres))
          end # before example
          let(:expected) { 'admin/publishers/genres/books/read' }

          it { expect(instance.template action_name).to be == expected }

          context 'when options[:controller_name] is set' do
            let(:resource_options) do
              super().merge :controller_name => 'TomesController'
            end # let
            let(:expected) { 'admin/publishers/genres/tomes/read' }

            it { expect(instance.template action_name).to be == expected }
          end # context
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
