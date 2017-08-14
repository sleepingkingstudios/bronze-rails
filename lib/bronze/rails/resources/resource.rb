# lib/bronze/rails/resources/resource.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/rails/resources'
require 'bronze/rails/resources/resource/associations'
require 'bronze/rails/resources/resource/base'
require 'bronze/rails/resources/resource/names'
require 'bronze/rails/resources/resource/templates'
require 'bronze/rails/services/routes_service'

module Bronze::Rails::Resources
  # Object representing a Rails resource. Provides methods to query properties
  # such as resourceful routes and template paths.
  class Resource
    include Bronze::Rails::Resources::Resource::Base
    include Bronze::Rails::Resources::Resource::Associations
    include Bronze::Rails::Resources::Resource::Names
    include Bronze::Rails::Resources::Resource::Templates

    # @param resource_class [Class] The base class representing instances of the
    #   resource.
    # @param resource_options [Hash] Additional options for the resource.
    def initialize resource_class, resource_options = {}
      super
    end # constructor
  end # class
end # module
