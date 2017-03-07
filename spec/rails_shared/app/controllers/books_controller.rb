# spec/rails_shared/app/controllers/books_controller.rb

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'

class BooksController < ApplicationController
  include Bronze::Rails::Resources::ResourcesController

  resource Spec::Book

  private

  def permitted_attributes
    %w(title series page_count)
  end # method permitted_attributes
end # class
