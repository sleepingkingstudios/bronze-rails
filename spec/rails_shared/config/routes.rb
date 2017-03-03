# spec/rails_shared/config/routes.rb

Rails.application.routes.draw do
  # See http://guides.rubyonrails.org/routing.html

  resources :books do
    resources :chapters do
      resources :sections
    end # resources
  end # resources
end # routes
