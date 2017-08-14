# spec/bronze/rails/resources/operation_strategy_spec.rb

require 'bronze/entities/entity'
require 'bronze/entities/operations/entity_operation_builder'

require 'bronze/rails/resources/operation_strategy'

RSpec.describe Bronze::Rails::Resources::OperationStrategy do
  describe '::for' do
    it { expect(described_class).to respond_to(:for).with(1).argument }

    describe 'with nil' do
      let(:error_message) { 'unknown builder strategy for nil' }

      it 'should raise an error' do
        expect { described_class.for nil }.
          to raise_error ArgumentError, error_message
      end # it
    end # describe

    describe 'with an object with an ::Operations constant' do
      example_class 'Spec::Novel', :base_class => Bronze::Entities::Entity

      before(:example) do
        class Spec::Novel
          Operations =
            Bronze::Entities::Operations::EntityOperationBuilder.new(self) do
              define_entity_operations
            end # new
        end # class
      end # before example

      it 'should return the Operations constant' do
        builder = described_class.for(Spec::Novel)

        expect(builder).to be Spec::Novel::Operations
      end # it
    end # describe

    describe 'with an entity class' do
      example_class 'Spec::Novel', :base_class => Bronze::Entities::Entity

      it 'should return an operation builder' do
        builder = described_class.for(Spec::Novel)

        expect(builder).
          to be_a Bronze::Entities::Operations::EntityOperationBuilder
        expect(builder.entity_class).to be Spec::Novel
      end # it
    end # describe
  end # describe
end # describe
