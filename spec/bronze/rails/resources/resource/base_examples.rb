# spec/bronze/rails/resources/resource/base_examples.rb

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Resources
  module Resource; end
end # module

module Spec::Resources::Resource
  module BaseExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Resource::Base methods' do
      describe '::new' do
        it { expect(described_class).to be_constructible.with(1..2).arguments }
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
