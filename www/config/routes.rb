# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations], controllers: {
    sessions: "users/sessions"
  }

  devise_scope :user do
    # we've disabled registrations to avoid sign ups, but we still want editable users
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'

    get 'sign_in_with_token', to: 'users/sessions#sign_in_with_token'
    get 'magic-authentication', to: "users/sessions#sign_in_with_magic_token"
    namespace :users do
      resources :magic_links, only: [:create]
    end
  end

  root "pages#home"
  get "comment-ca-marche", to: "pages#aide", as: "aide"
  get "guide-de-recensement", to: "pages#guide", as: "guide"
  get "confirmation-de-participation", to: "pages#confirmation_inscription", as: "enrollment_success"

  resources :objets, only: [:index, :show] do
    resources :recensements, except: [:index, :show, :destroy]
  end
  get "objets/ref_pop/:ref_pop", to: "objets#show_by_ref_pop"

  resources :communes, only: [:index] do
    resources :enrollments, only: [:new, :create], controller: "communes/enrollments"
    resource :completion, only: [:new, :create, :show], controller: "communes/completions"
    resources :objets, only: [:index], controller: "communes/objets" do
      collection do
        get "liste-imprimable", to: "communes/objets#index_print", as: :printable_list
      end
    end
  end

  # get "inscription", to: "/"

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
  get "health/js_error", to: "health#js_error"
end
