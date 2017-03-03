# spec/fixtures/entities/section.rb

require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class Section < Bronze::Entities::Entity
    include Bronze::Rails::Entity
  end # class
end # module
