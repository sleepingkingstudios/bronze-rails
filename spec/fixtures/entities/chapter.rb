# spec/fixtures/entities/chapter.rb

require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Chapter < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :title,      String
    attribute :word_count, Integer

    belongs_to :book, :class_name => 'Spec::Book'

    class Contract < Bronze::Entities::Contracts::EntityContract
      validate :attribute_types => true

      validate :title, :present => true
    end # class
  end # class
end # module
