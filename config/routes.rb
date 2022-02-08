# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root "pages#home"

  resources :objets, only: [:index, :show]
  resources :communes, only: [:index]
end
