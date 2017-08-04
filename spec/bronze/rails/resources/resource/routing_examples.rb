# spec/bronze/rails/resources/resource/routing_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/rails/resources/resource/base_examples'

require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module RoutingExamples
    extend  RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    include Spec::Resources::Resource::BaseExamples

    shared_examples 'should implement the Resource::Routing methods' do
      describe '#edit_resource_path' do
        let(:resource) { resource_class.new }
        let(:expected) { "/books/#{resource.id}/edit" }

        it 'should define the method' do
          expect(instance).
            to respond_to(:edit_resource_path).
            with(1).argument.
            and_unlimited_arguments
        end # it

        describe 'with the resource' do
          it { expect(instance.edit_resource_path resource).to be == expected }
        end # describe

        describe 'with the resource id' do
          it 'should generate the url' do
            expect(instance.edit_resource_path resource.id).to be == expected
          end # it
        end # describe

        wrap_context 'when the resource has many namespaces' do
          let(:expected) { "/admin/api/books/#{resource.id}/edit" }

          describe 'with the resource' do
            it 'should generate the url' do
              expect(instance.edit_resource_path resource).to be == expected
            end # it
          end # describe

          describe 'with the resource id' do
            it 'should generate the url' do
              expect(instance.edit_resource_path resource.id).to be == expected
            end # it
          end # describe
        end # wrap_context

        wrap_context 'when the resource has a namespace and a parent resource' \
        do
          let(:expected) do
            "/admin/books/#{book.id}/chapters/#{resource.id}/edit"
          end # let

          describe 'with the parent resource id and resource id' do
            it 'should generate the url' do
              expect(instance.edit_resource_path book.id, resource.id).
                to be == expected
            end # it
          end # describe

          describe 'with the parent resource and resource' do
            it 'should generate the url' do
              expect(instance.edit_resource_path book, resource).
                to be == expected
            end # it
          end # describe
        end # wrap_context

        wrap_context 'when the resource has many parent resources' do
          let(:expected) do
            "/books/#{book.id}/chapters/#{chapter.id}/sections/#{resource.id}" \
            '/edit'
          end # let

          describe 'with the parent resource ids and resource id' do
            it 'should generate the url' do
              expect(
                instance.edit_resource_path book.id, chapter.id, resource.id
              ). # end expect
                to be == expected
            end # it
          end # describe

          describe 'with the parent resources and resource id' do
            it 'should generate the url' do
              expect(instance.edit_resource_path book, chapter, resource).
                to be == expected
            end # it
          end # describe
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

      describe '#resource_path' do
        let(:resource) { resource_class.new }
        let(:expected) { "/books/#{resource.id}" }

        it 'should define the method' do
          expect(instance).
            to respond_to(:resource_path).
            with(1).argument.
            and_unlimited_arguments
        end # it

        describe 'with the resource' do
          it { expect(instance.resource_path resource).to be == expected }
        end # describe

        describe 'with the resource id' do
          it { expect(instance.resource_path resource.id).to be == expected }
        end # describe

        wrap_context 'when the resource has many namespaces' do
          let(:expected) { "/admin/api/books/#{resource.id}" }

          describe 'with the resource' do
            it { expect(instance.resource_path resource).to be == expected }
          end # describe

          describe 'with the resource id' do
            it { expect(instance.resource_path resource.id).to be == expected }
          end # describe
        end # wrap_context

        wrap_context 'when the resource has a namespace and a parent resource' \
        do
          let(:expected) { "/admin/books/#{book.id}/chapters/#{resource.id}" }

          describe 'with the parent resource id and resource id' do
            it 'should generate the url' do
              expect(instance.resource_path book.id, resource.id).
                to be == expected
            end # it
          end # describe

          describe 'with the parent resource and resource' do
            it 'should generate the url' do
              expect(instance.resource_path book, resource).
                to be == expected
            end # it
          end # describe
        end # wrap_context

        wrap_context 'when the resource has many parent resources' do
          let(:expected) do
            "/books/#{book.id}/chapters/#{chapter.id}/sections/#{resource.id}"
          end # let

          describe 'with the parent resource ids and resource id' do
            it 'should generate the url' do
              expect(instance.resource_path book.id, chapter.id, resource.id).
                to be == expected
            end # it
          end # describe

          describe 'with the parent resources and resource id' do
            it 'should generate the url' do
              expect(instance.resource_path book, chapter, resource).
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
    end # shared_examples
  end # module
end # module
