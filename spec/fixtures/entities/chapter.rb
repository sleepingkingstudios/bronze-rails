# spec/fixtures/entities/chapter.rb

require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Chapter < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :title, String
  end # class
end # module
