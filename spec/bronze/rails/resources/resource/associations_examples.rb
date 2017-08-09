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

      describe '#namespace' do
        shared_examples 'should add the namespace to the resource' do
          it 'should add the namespace to the resource' do
            expect { instance.namespace name }.
              to change(instance.namespaces, :count).by(1)

            namespace = instance.namespaces.last
            expect(namespace.fetch :name).to be == name.intern
            expect(namespace.fetch :type).to be :namespace
          end # it
        end # shared_examples

        let(:name) { 'alpha' }

        it { expect(instance).to respond_to(:namespace).with(1).argument }

        include_examples 'should add the namespace to the resource'

        context 'when the resource has many namespaces' do
          before(:example) do
            instance.namespace :admin
            instance.namespace :api
          end # before example

          include_examples 'should add the namespace to the resource'
        end # context

        context 'when the resource has a namespace and a parent resource' do
          let(:book)           { Spec::Book.new }
          let(:resource_class) { Spec::Chapter }

          before(:example) do
            instance.namespace       :admin
            instance.parent_resource Spec::Book
          end # before example

          include_examples 'should add the namespace to the resource'
        end # context

        context 'when the resource has many parent resources' do
          let(:book)           { Spec::Book.new }
          let(:chapter)        { Spec::Chapter.new }
          let(:resource_class) { Spec::Section }

          before(:example) do
            instance.parent_resource Spec::Book
            instance.parent_resource Spec::Chapter
          end # before example

          include_examples 'should add the namespace to the resource'
        end # context
      end # describe

      describe '#parent_resource' do
        shared_examples 'should add the parent to the resource' do |proc|
          it 'should add the parent to the resource' do
            expect { instance.parent_resource parent_class, parent_options }.
              to change(instance.namespaces, :count).by(1)

            namespace = instance.namespaces.last
            expect(namespace.fetch :name).to be == parent_name
            expect(namespace.fetch :type).to be :resource

            resource = namespace.fetch :resource
            expect(resource.plural_resource_name).to be == parent_name
            expect(resource.resource_class).to be parent_class

            instance_exec(resource, &proc) if proc
          end # it
        end # shared_examples

        let(:parent_class)   { Spec::Book }
        let(:parent_options) { {} }
        let(:parent_name)    { 'books' }

        it 'should define the method' do
          expect(instance).to respond_to(:parent_resource).with(1..2).arguments
        end # it

        include_examples 'should add the parent to the resource'

        describe 'when the parent :resource_name is set' do
          let(:parent_options) { super().merge :resource_name => parent_name }
          let(:parent_name)    { 'tomes' }

          include_examples 'should add the parent to the resource'
        end # describe

        context 'when the resource has many namespaces' do
          let(:expected) { instance.namespaces[0...-1] }

          before(:example) do
            instance.namespace :admin
            instance.namespace :api
          end # before example

          include_examples 'should add the parent to the resource',
            lambda { |resource|
              expect(resource.namespaces).to be == expected
            } # end lambda
        end # context

        context 'when the resource has a namespace and a parent resource' do
          let(:book)           { Spec::Book.new }
          let(:resource_class) { Spec::Chapter }
          let(:expected)       { instance.namespaces[0...-1] }

          before(:example) do
            instance.namespace       :admin
            instance.parent_resource Spec::Book
          end # before example

          include_examples 'should add the parent to the resource',
            lambda { |resource|
              expect(resource.namespaces).to be == expected
            } # end lambda
        end # context

        context 'when the resource has many parent resources' do
          let(:book)           { Spec::Book.new }
          let(:chapter)        { Spec::Chapter.new }
          let(:resource_class) { Spec::Section }
          let(:expected)       { instance.namespaces[0...-1] }

          before(:example) do
            instance.parent_resource Spec::Book
            instance.parent_resource Spec::Chapter
          end # before example

          include_examples 'should add the parent to the resource',
            lambda { |resource|
              expect(resource.namespaces).to be == expected
            } # end lambda
        end # context
      end # describe

      describe '#parent_resources' do
        include_examples 'should have reader', :parent_resources, []

        context 'when the resource has many namespaces' do
          before(:example) do
            instance.namespace :admin
            instance.namespace :api
          end # before example

          it { expect(instance.parent_resources).to be == [] }
        end # context

        context 'when the resource has a namespace and a parent resource' do
          let(:book)           { Spec::Book.new }
          let(:resource_class) { Spec::Chapter }
          let(:expected) do
            instance.namespaces.
              select { |hsh| hsh[:type] == :resource }.
              map { |hsh| hsh[:resource] }
          end # let

          before(:example) do
            instance.namespace       :admin
            instance.parent_resource Spec::Book
          end # before example

          it { expect(instance.parent_resources).to be == expected }
        end # context

        context 'when the resource has many parent resources' do
          let(:book)           { Spec::Book.new }
          let(:chapter)        { Spec::Chapter.new }
          let(:resource_class) { Spec::Section }
          let(:expected) do
            instance.namespaces.
              select { |hsh| hsh[:type] == :resource }.
              map { |hsh| hsh[:resource] }
          end # let

          before(:example) do
            instance.parent_resource Spec::Book
            instance.parent_resource Spec::Chapter
          end # before example

          it { expect(instance.parent_resources).to be == expected }
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
