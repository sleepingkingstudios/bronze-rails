# spec/fixtures/entities/book.rb

require 'bronze/entities/entity'

module Spec
  class Book < Bronze::Entities::Entity
    attribute :title, String
  end # class
end # module
