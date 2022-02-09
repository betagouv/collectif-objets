# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  devise_scope :user do
    get 'sign_in_with_token', to: 'users/sessions#sign_in_with_token'
    namespace :users do
      resources :magic_links, only: [:create]
    end
  end

  root "pages#home"

  resources :objets, only: [:index, :show]
  resources :communes, only: [:index]
end
