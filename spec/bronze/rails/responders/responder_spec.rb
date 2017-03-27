# spec/bronze/rails/responders/responder_spec.rb

require 'rails_helper'

require 'bronze/rails/responders/responder'
require 'bronze/rails/responders/responder_examples'

RSpec.describe Bronze::Rails::Responders::Responder do
  include Spec::Examples::ResponderExamples

  let(:resource_class)   { Spec::Book }
  let(:resource_options) { {} }
  let(:resource_definition) do
    Bronze::Rails::Resources::Resource.new resource_class, resource_options
  end # let
  let(:resources)        { {} }
  let(:instance_options) { { :resources => resources } }
  let(:instance) do
    described_class.new resource_definition, instance_options
  end # let

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  include_examples 'should implement the Responder methods'

  describe '#resource_path' do
    let(:book)     { Spec::Book.new }
    let(:expected) { "/books/#{book.id}" }

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
