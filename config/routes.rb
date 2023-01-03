# rubocop:disable Metrics/BlockLength
# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  ## -----
  ## DEVISE
  ## -----

  devise_for :admin_users, skip: [:registrations]
  authenticate :admin_user do
    mount Sidekiq::Web => "/sidekiq"
  end

  devise_for :users, skip: [:registrations], controllers: {
    sessions: "users/sessions"
  }
  devise_scope :user do
    # we've disabled registrations to avoid sign ups, but we still want editable users
    get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
    put "users" => "devise/registrations#update", :as => "user_registration"

    get "users/sign_in_with_token", to: "users/sessions#sign_in_with_token"
    get "magic-authentication", to: "users/sessions#sign_in_with_magic_token"
    namespace :users do
      resources :magic_links, only: [:create]
    end
  end

  devise_for :conservateurs, only: %i[sessions passwords]
  devise_scope :conservateur do
    # we've disabled registrations to avoid sign ups, but we still want editable conservateurs
    get "conservateurs/edit" => "devise/registrations#edit", :as => "edit_conservateur_registration"
  end

  ## ------
  ## PUBLIC
  ## ------

  root "pages#home"
  controller :pages do
    get :connexion
    get :stats
    get :presse
    get :conditions
    get :mentions_legales
    get :confidentialite
    get "comment-ca-marche", action: :aide, as: :aide
    get "guide-de-recensement", action: :guide, as: :guide
    get :fiches
    get :fiche, action: :pdf_embed
    get :pdf, action: :pdf_download, as: :pdf_download
    get :admin
    get :plan
    get :accessibilite
  end
  resources :survey_votes, only: %w[new create]

  resources :departements, only: %i[index show]
  resources :objets, only: %i[index show]
  get "objets/ref_pop/:palissy_REF", to: "objets#show_by_ref_pop"

  ## --------
  ## COMMUNES
  ## --------

  resources :communes, module: :communes, only: [] do
    resource :completion, only: %i[new create show]
    resource :recompletion, only: %i[new create]
    resources :objets, only: %i[index show] do
      resources :recensements, except: %i[index show destroy]
    end
    resource :formulaire, only: [:show]
    resources :dossiers, only: [:show]
    resources :campaign_recipients, only: [:update]
  end

  ## -------------
  ## CONSERVATEURS
  ## -------------

  namespace :conservateurs do
    resources :departements, only: %i[index show] do
      resources :communes, only: [:index]
    end
    resources :communes, only: [:show] do
      collection do
        post :autocomplete
      end
    end
    resources :objets, only: [] do
      resources :recensements, only: [] do
        resource :analyse, only: %i[edit update]
      end
    end
    resources :dossiers, only: [:show] do
      resource :accept, only: %i[new create update]
      resource :reject, only: %i[new create update]
    end
  end

  ## -----
  ## ADMIN
  ## -----

  namespace :admin do
    resources :communes, only: %i[index show]
    resources :conservateurs, except: [:destroy] do
      get :impersonate
      collection do
        post :stop_impersonating
        post :toggle_impersonate_mode
      end
    end
    resources :dossiers, only: [:update]
    resources :users, only: [] do
      get :impersonate
      collection do
        post :stop_impersonating
        post :toggle_impersonate_mode
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
      resources :recipients, controller: "campaign_recipients", only: %i[show update] do
        get :mail_preview
      end
      resources :emails, controller: "campaign_emails", only: [] do
        get :redirect_to_sib_preview
      end
    end
    resources :active_admin_comments, only: %i[create destroy], controller: "comments"
    resources :exports, only: [:index]
    resources :palissy_exports, only: %i[new create show destroy]
    resources :memoire_exports, only: %i[new create show destroy]
    resources :attachments, only: [] do
      post :rotate
    end
  end

  # ------
  # DEMOS
  # ------

  get "demos/:namespace/:name", to: "demos#show", as: :demo

  # --------------
  # HEALTH & DEBUG
  # --------------

  namespace :health do
    scope controller: :health do
      get :raise_on_purpose
      get :js_error
      get :slow_image if Rails.env.development?
    end
  end

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  resources :mail_previews, only: [:index] if Rails.configuration.x.environment_specific_name != "production"
end

# rubocop:enable Metrics/BlockLength
