# spec/fixtures/entities/magazine.rb

require 'bronze/entities/contracts/entity_contract'
require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Magazine < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :title,     String
    attribute :volume,    Integer
    attribute :publisher, String, :allow_nil => true

    unique :title, :volume

    class Contract < Bronze::Entities::Contracts::EntityContract
      validate :attribute_types => true

      validate :title,  :present => true
      validate :volume, :present => true
    end # class
  end # class
end # module
