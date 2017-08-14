# spec/rails_shared/app/controllers/dragons_controller.rb

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/dragon'
require 'fixtures/entities/dungeon'

class DragonsController < ApplicationController
  include Bronze::Rails::Resources::ResourcesController

  resource Spec::Dragon do
    parent_resource :dungeons,
      :class            => Spec::Dungeon,
      :association_name => :lair
  end # resource

  private

  def permitted_attributes
    %w(name wingspan)
  end # method permitted_attributes
end # class
