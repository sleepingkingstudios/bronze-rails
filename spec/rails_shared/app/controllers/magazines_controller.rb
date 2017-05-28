# spec/rails_shared/app/controllers/magazines_controller.rb

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/magazine'

class MagazinesController < ApplicationController
  include Bronze::Rails::Resources::ResourcesController

  resource Spec::Magazine

  private

  def permitted_attributes
    %w(title volume publisher)
  end # method permitted_attributes
end # class
