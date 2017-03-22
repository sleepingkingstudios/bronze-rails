# spec/rails_5_0/app/controllers/application_controller.rb

require 'patina/collections/simple/repository'

class ApplicationController < ActionController::Base
  private

  def repository
    @repository ||= Patina::Collections::Simple::Repository.new
  end # method repository
end # class
