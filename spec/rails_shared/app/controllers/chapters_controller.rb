# spec/rails_shared/app/controllers/chapters_controller.rb

require 'bronze/rails/resources/resources_controller'

require 'fixtures/entities/book'
require 'fixtures/entities/chapter'

class ChaptersController < ApplicationController
  include Bronze::Rails::Resources::ResourcesController

  resource Spec::Chapter,
    :ancestors =>
      [
        {
          :name  => :books,
          :type  => :resource,
          :class => Spec::Book
        } # end books
      ] # end ancestors

  private

  def permitted_attributes
    %w(title word_count)
  end # method permitted_attributes
end # class
