# spec/rails_shared/config/routes.rb

Rails.application.routes.draw do
  # See http://guides.rubyonrails.org/routing.html

  root 'books#index'

  namespace :admin do
    namespace :api do
      resources :books
    end # namespace

    resources :books do
      resources :chapters
    end # resources
  end # namespace

  resources :books do
    resources :chapters do
      resources :sections
    end # resources
  end # resources
end # routes
