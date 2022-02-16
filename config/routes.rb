# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  devise_scope :user do
    get 'sign_in_with_token', to: 'users/sessions#sign_in_with_token'
    get 'magic-authentication', to: "users/sessions#sign_in_with_magic_token"
    namespace :users do
      resources :magic_links, only: [:create]
    end
  end

  root "pages#home"
  get "permanence", to: "pages#permanence"
  get "comment-ca-marche", to: "pages#aide", as: "aide"
  get "confirmation-de-participation", to: "pages#confirmation_inscription", as: "enrollment_success"

  resources :objets, only: [:index, :show] do
    collection do
      get "liste-imprimable", to: "objets#index_print", as: :printable_list
    end
  end
  get "objets/ref_pop/:ref_pop", to: "objets#show_by_ref_pop"

  resources :communes, only: [:index]

  resources :enrollments, only: [:new, :create]
  get "inscription", to: "enrollments#new"

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
end
