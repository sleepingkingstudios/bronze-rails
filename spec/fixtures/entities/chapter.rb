# spec/fixtures/entities/chapter.rb

require 'bronze/entities/entity'

module Spec
  class Chapter < Bronze::Entities::Entity
    attribute :title, String
  end # class
end # module
