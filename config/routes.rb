# frozen_string_literal: true

require 'sidekiq/web'
require "sidekiq/throttled/web"

Rails.application.routes.draw do
  # Replace Sidekiq Queues with enhanced version!
  Sidekiq::Throttled::Web.enhance_queues_tab!

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

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

  devise_for :conservateurs, only: [:sessions, :passwords]
  devise_scope :conservateur do
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
  get "/fiches", to: "pages#fiches"
  get "/fiche", to: "pages#pdf_embed"
  get "/pdf", to: "pages#pdf_download", as: "pdf_download"
  get "/connexion", to: "pages#connexion", as: "connexion"

  resources :objets, only: [:index, :show]
  get "objets/ref_pop/:palissy_REF", to: "objets#show_by_ref_pop"

  resources :communes, only: [] do
    resource :completion, only: [:new, :create, :show], controller: "communes/completions"
    resource :recompletion, only: [:new, :create], controller: "communes/recompletions"
    resources :objets, only: [:index, :show], controller: "communes/objets" do
      resources :recensements, except: [:index, :show, :destroy], controller: "communes/recensements"
    end
    resource :formulaire, only: [:show], controller: "communes/formulaires"
    resources :dossiers, only: [:show], controller: "communes/dossiers"
    resources :campaign_recipients, only: [:update], controller: "communes/campaign_recipients"
  end

  resources :departements, only: [:index, :show]

  namespace :conservateurs do
    resources :departements, only: [:index, :show] do
      resources :communes, only: [:index]
    end
    resources :communes, only: [:show] do
      collection do
        post :autocomplete
      end
    end
    resources :objets, only: [] do
      resources :recensements, only: [] do
        resource :analyse, only: [:edit, :update]
      end
    end
    resources :dossiers, only: [:show] do
      resource :accept, only: [:new, :create, :update]
      resource :reject, only: [:new, :create, :update]
    end
  end

  resources :campaigns do
    get :show_statistics
    get :edit_recipients
    patch :update_recipients
    patch :update_status
    get :mail_previews
    if Rails.configuration.x.environment_specific_name != "production"
      post :force_start
      post :force_step_up
    end
    post :refresh_delivery_infos
    post :refresh_stats
    resources :recipients, controller: "campaign_recipients", only: [:show, :update] do
      get :mail_preview
    end
    resources :emails, controller: "campaign_emails", only: [] do
      get :redirect_to_sib_preview
    end
  end

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
  get "health/js_error", to: "health#js_error"

  namespace :api do
    namespace :v1 do
      resources :departements, only: [:index]
      resources :communes, only: [:index]
    end
  end

  if Rails.env.development?
    get "health/slow_image", to: "health#slow_image", as: "slow_image"
    mount Lookbook::Engine, at: "/lookbook"
  end

  if Rails.configuration.x.environment_specific_name != "production"
    resources :mail_previews, only: [:index]
  end
end
