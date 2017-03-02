# spec/bronze/rails/entity_spec.rb

require 'bronze/entities/entity'
require 'bronze/rails/entity'

RSpec.describe Bronze::Rails::Entity do
  let(:described_class) do
    Class.new(Bronze::Entities::Entity) do
      include Bronze::Rails::Entity
    end # let
  end # let
  let(:instance) { described_class.new }

  describe '#to_param' do
    it { expect(instance).to respond_to(:to_param) }

    it 'should return a string representation of the primary key' do
      expect(instance.to_param).to be == instance.id
    end # it
  end # describe
end # describe
