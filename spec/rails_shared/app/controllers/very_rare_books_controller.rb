# spec/rails_shared/app/controllers/very_rare_books_controller.rb

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'

class VeryRareBooksController < ApplicationController
  include Bronze::Rails::Resources::ResourcesController

  resource Spec::Book,
    :controller_name   => 'VeryRareBooksController',
    :resource_name     => 'rare_books',
    :serialization_key => :first_edition

  private

  def permitted_attributes
    %w(title series page_count)
  end # method permitted_attributes
end # class
