# lib/bronze/rails/services/routes_service.rb

require 'bronze/rails/services'

module Bronze::Rails::Services
  # Service object that wraps the route helpers of a Rails application.
  class RoutesService
    include ::Rails.application.routes.url_helpers

    def self.instance
      @instance ||= new
    end # class method instance
  end # class
end # module
