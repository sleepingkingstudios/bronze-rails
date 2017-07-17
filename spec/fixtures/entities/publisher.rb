# spec/fixtures/entities/publisher.rb

require 'bronze/entities/contracts/entity_contract'
require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Publisher < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :name,    String
    attribute :address, String,  :allow_nil => true

    has_many :books, :class_name => 'Spec::Book'

    class Contract < Bronze::Entities::Contracts::EntityContract
      validate :attribute_types => true
    end # class
  end # class
end # module
