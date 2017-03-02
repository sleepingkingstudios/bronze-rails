# spec/fixtures/entities/archived_periodical.rb

require 'bronze/entities/entity'

module Spec
  class ArchivedPeriodical < Bronze::Entities::Entity
    attribute :title, String
  end # class
end # module
