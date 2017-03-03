# spec/fixtures/entities/archived_periodical.rb

require 'bronze/entities/entity'

require 'bronze/rails/entity'

module Spec
  class ArchivedPeriodical < Bronze::Entities::Entity
    include Bronze::Rails::Entity

    attribute :title, String
  end # class
end # module
