# spec/fixtures/entities/book.rb

require 'bronze/entities/contracts/entity_contract'
require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Book < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :title,      String
    attribute :series,     String,  :allow_nil => true
    attribute :page_count, Integer, :allow_nil => true

    class Contract < Bronze::Entities::Contracts::EntityContract
      validate :attribute_types => true

      validate :title, :present => true
    end # class
  end # class
end # module
