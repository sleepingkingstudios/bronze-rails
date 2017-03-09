# spec/fixtures/entities/dragon.rb

require 'bronze/entities/contracts/entity_contract'
require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Dragon < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :name,     String
    attribute :wingspan, Integer

    belongs_to :lair, :class_name => 'Spec::Dungeon'

    class Contract < Bronze::Entities::Contracts::EntityContract
      validate :attribute_types => true

      validate :name, :present => true
    end # class
  end # class
end # module
