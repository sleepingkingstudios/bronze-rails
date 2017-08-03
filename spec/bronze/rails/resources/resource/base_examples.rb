# spec/bronze/rails/resources/resource/base_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'bronze/rails/resources/resource'

require 'fixtures/entities/chapter'
require 'fixtures/entities/section'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module BaseExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the resource has many namespaces' do
      let(:namespaces) do
        [
          { :name => :admin, :type => :namespace },
          { :name => :api,   :type => :namespace }
        ] # end namespaces
      end # let

      before(:example) do
        allow(instance).to receive(:namespaces).and_return(namespaces)
      end # before
    end # shared_context

    shared_context 'when the resource has a namespace and a parent resource' do
      let(:book)           { Spec::Book.new }
      let(:resource_class) { Spec::Chapter }
      let(:resources) do
        {
          :books => Bronze::Rails::Resources::Resource.new(Spec::Book)
        } # end resources
      end # let
      let(:namespaces) do
        [
          { :name => :admin, :type => :namespace },
          {
            :name     => :books,
            :type     => :resource,
            :resource => resources[:books]
          } # end books
        ] # end namespaces
      end # let

      before(:example) do
        allow(resources[:books]).
          to receive(:namespaces).
          and_return(namespaces[0..0])

        allow(instance).to receive(:namespaces).and_return(namespaces)
      end # before
    end # shared_context

    shared_context 'when the resource has many parent resources' do
      let(:book)           { Spec::Book.new }
      let(:chapter)        { Spec::Chapter.new }
      let(:resource_class) { Spec::Section }
      let(:resources) do
        {
          :books    => Bronze::Rails::Resources::Resource.new(Spec::Book),
          :chapters => Bronze::Rails::Resources::Resource.new(Spec::Chapter)
        } # end resources
      end # let
      let(:namespaces) do
        [
          {
            :name     => :books,
            :type     => :resource,
            :resource => resources[:books]
          }, # end books
          {
            :name     => :chapters,
            :type     => :resource,
            :resource => resources[:chapters]
          } # end chapters
        ] # end namespaces
      end # let

      before(:example) do
        allow(resources[:chapters]).
          to receive(:namespaces).
          and_return(namespaces[0..0])

        allow(instance).to receive(:namespaces).and_return(namespaces)
      end # before
    end # shared_context

    shared_examples 'should implement the Resource::Base methods' do
      describe '::new' do
        it { expect(described_class).to be_constructible.with(1..2).arguments }
      end # describe

      describe '#namespaces' do
        include_examples 'should have reader', :namespaces, []
      end # describe

      describe '#resource_class' do
        include_examples 'should have reader',
          :resource_class,
          ->() { resource_class }
      end # describe

      describe '#resource_options' do
        include_examples 'should have reader',
          :resource_options,
          ->() { be == resource_options }

        describe 'with custom resource options with string keys' do
          let(:resource_options) { { :custom_option => 'custom value' } }
          let(:expected) do
            tools.hash.convert_keys_to_symbols(resource_options)
          end # let

          it { expect(instance.resource_options).to be == expected }
        end # describe
      end # describe
    end # shared_examples
  end # module
end # module
