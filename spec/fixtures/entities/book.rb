# spec/fixtures/entities/book.rb

require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Book < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :title, String
  end # class
end # module
