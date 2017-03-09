# spec/fixtures/entities/dungeon.rb

require 'bronze/entities/contracts/entity_contract'
require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Dungeon < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :name, String

    has_many :dragons, :class_name => 'Spec::Dragon'
  end # class
end # module
