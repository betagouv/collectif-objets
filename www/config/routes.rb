# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations], controllers: {
    sessions: "users/sessions"
  }
  devise_scope :user do
    # we've disabled registrations to avoid sign ups, but we still want editable users
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'

    get 'users/sign_in_with_token', to: 'users/sessions#sign_in_with_token'
    get 'magic-authentication', to: "users/sessions#sign_in_with_magic_token"
    namespace :users do
      resources :magic_links, only: [:create]
    end
  end

  devise_for :conservateurs, only: [:sessions], controllers: {
    sessions: "conservateurs/sessions"
  }
  devise_scope :conservateur do
    get 'conservateurs/sign_in_with_token', to: 'conservateurs/sessions#sign_in_with_token'
    # we've disabled registrations to avoid sign ups, but we still want editable conservateurs
    get 'conservateurs/edit' => 'devise/registrations#edit', :as => 'edit_conservateur_registration'
  end

  root "pages#home"
  get "/stats", to: "pages#stats"
  get "/conditions", to: "pages#cgu"
  get "/mentions_legales", to: "pages#mentions_legales"
  get "/confidentialite", to: "pages#confidentialite"
  get "comment-ca-marche", to: "pages#aide", as: "aide"
  get "guide-de-recensement", to: "pages#guide", as: "guide"

  resources :objets, only: [:index, :show] do
    resources :recensements, except: [:index, :show, :destroy]
  end
  get "objets/ref_pop/:palissy_REF", to: "objets#show_by_ref_pop"

  resources :communes, only: [:index] do
    resources :enrollments, only: [:new, :create], controller: "communes/enrollments"
    resource :completion, only: [:new, :create, :show], controller: "communes/completions"
    resource :recompletion, only: [:new, :create], controller: "communes/recompletions"
    resources :objets, only: [:index], controller: "communes/objets" do
      collection do
        get "liste-imprimable", to: "communes/objets#index_print", as: :printable_list
      end
    end
  end

  namespace :conservateurs do
    resources :departements, only: [:index, :show] do
      resources :communes, only: [:index]
    end
    resources :communes, only: [:show] do
      collection do
        post :autocomplete
      end
    end
    resources :objets, only: [:show] do
      resource :notes, only: [:update], controller: "objets/notes"
    end
    resources :recensements, only: [:update]
    resources :dossiers, only: [] do
      resource :rapport, only: [:update]
      resource :accept, only: [:new, :create]
      resource :reject, only: [:new, :create]
      resource :private_notes, only: [:update], controller: "dossiers/private_notes"
    end
  end

  # get "inscription", to: "/"

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
  get "health/js_error", to: "health#js_error"

  post "webhooks/chatwoot", to: "webhooks#chatwoot"
end
