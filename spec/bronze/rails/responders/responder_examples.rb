# spec/bronze/rails/responders/responder_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/rails/resources/resource'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

module Spec
  module Examples; end
end # module

module Spec::Examples
  module ResponderExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the resource has a parent resource' do
      let(:resource_class) { Spec::Chapter }
      let(:resource_definition) do
        Bronze::Rails::Resources::Resource.new(
          resource_class,
          resource_options
        ) do
          parent_resource :books, :class => Spec::Book
        end # let
      end # let
    end # shared_context

    shared_context 'when the resource has a grandparent and parent resource' do
      let(:resource_class) { Spec::Section }
      let(:resource_definition) do
        Bronze::Rails::Resources::Resource.new(
          resource_class,
          resource_options
        ) do
          parent_resource :books,    :class => Spec::Book
          parent_resource :chapters, :class => Spec::Chapter
        end # let
      end # let
    end # shared_context

    shared_context 'when the locale is set' do
      let(:locale)           { 'fr-FR' }
      let(:instance_options) { super().merge :locale => locale }
    end # shared_context

    shared_examples 'should implement the Responder methods' do
      describe '#locale' do
        it { expect(instance).to have_reader(:locale).with_value(nil) }

        wrap_context 'when the locale is set' do
          it { expect(instance.locale).to be == locale }
        end # context
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
      end # describe

      describe '#resources_path' do
        it 'should define the private reader' do
          expect(instance).not_to respond_to(:resources_path)

          expect(instance).
            to respond_to(:resources_path, true).
            with(0).arguments
        end # it

        it { expect(instance.send :resources_path).to be == '/books' }
      end # describe
    end # shared_examples
  end # module
end # module
