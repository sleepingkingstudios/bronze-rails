# lib/bronze/rails/entity.rb

require 'bronze/rails'

module Bronze::Rails
  # Adapter to use Bronze entities in a Rails application.
  module Entity
    def to_param
      id.to_s
    end # method to_param
  end # module
end # module
