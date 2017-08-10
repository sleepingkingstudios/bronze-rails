# spec/bronze/rails/resources/resource/associations_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/rails/resources/resource/base_examples'

require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module AssociationsExamples
    extend  RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    include Spec::Resources::Resource::BaseExamples

    shared_examples 'should implement the Resource::Associations methods' do
      describe '#association_key' do
        include_examples 'should have reader', :association_key, :book

        it 'should alias the method' do
          expect(instance).to alias_method(:association_key).as(:parent_key)
        end # it

        context 'when options[:association_name] is set' do
          let(:resource_options) do
            super().merge :association_name => 'tome'
          end # let

          it { expect(instance.association_key).to be == :tome }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) do
            super().merge :resource_name => 'tome'
          end # let

          it { expect(instance.association_key).to be == :tome }
        end # context
      end # describe

      describe '#association_name' do
        include_examples 'should have reader',
          :association_name,
          ->() { be == 'book' }

        it 'should alias the method' do
          expect(instance).to alias_method(:association_name).as(:parent_name)
        end # it

        context 'when options[:association_name] is a singular string' do
          let(:resource_options) do
            super().merge :association_name => 'tome'
          end # let

          it { expect(instance.association_name).to be == 'tome' }
        end # context

        context 'when options[:association_name] is a plural string' do
          let(:resource_options) do
            super().merge :association_name => 'tomes'
          end # let

          it { expect(instance.association_name).to be == 'tomes' }
        end # context

        context 'when options[:association_name] is a singular symbol' do
          let(:resource_options) do
            super().merge :association_name => :tome
          end # let

          it { expect(instance.association_name).to be == 'tome' }
        end # context

        context 'when options[:association_name] is a plural symbol' do
          let(:resource_options) do
            super().merge :association_name => :tomes
          end # let

          it { expect(instance.association_name).to be == 'tomes' }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) { super().merge :resource_name => :tome }

          it { expect(instance.association_name).to be == 'tome' }
        end # context
      end # describe

      describe '#foreign_key' do
        include_examples 'should have reader', :foreign_key, :book_id

        context 'when options[:association_name] is set' do
          let(:resource_options) do
            super().merge :association_name => 'tomes'
          end # let

          it { expect(instance.foreign_key).to be == :tome_id }
        end # context

        context 'when options[:resource_name] is set' do
          let(:resource_options) do
            super().merge :resource_name => 'tome'
          end # let

          it { expect(instance.foreign_key).to be == :tome_id }
        end # context
      end # describe

      describe '#parent_resources' do
        let(:expected) do
          instance.namespaces.
            select { |hsh| hsh[:type] == :resource }.
            map { |hsh| hsh[:resource] }
        end # let

        include_examples 'should have reader', :parent_resources, []

        wrap_context 'when the resource has many namespaces' do
          it { expect(instance.parent_resources).to be == [] }
        end # wrap_context

        wrap_context 'when the resource has a namespace and a parent resource' \
        do
          it { expect(instance.parent_resources).to be == expected }
        end # context

        wrap_context 'when the resource has many parent resources' do
          it { expect(instance.parent_resources).to be == expected }
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
