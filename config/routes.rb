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
    get :stats
    get :conditions
    get :mentions_legales
    get :confidentialite
    get "comment-ca-marche", action: :aide, as: :aide
    get "guide-de-recensement", action: :guide, as: :guide
    get :pdf, action: :pdf_download, as: :pdf_download
    get :admin
    get :plan
    get :declaration_accessibilite
    get :schema_pluriannuel_accessibilite
    get :accueil_conservateurs
  end
  get "campaigns.ics", to: "pages#campaigns_ics", as: :campaigns_ics
  resources :fiches, only: %i[index show]
  get "/presse", to: "presse#index", as: :presse
  get "/presse/:id", to: "presse#show", as: :article_presse
  resources :survey_votes, only: %w[new create]

  resources :departements, only: %i[index show]
  resources :objets, only: %i[index show]
  get "objets/ref_pop/:palissy_REF", to: "objets#show_by_ref_pop"
  resources :contenus, only: %i[show], controller: "content_blobs", as: "content_blobs"

  ## --------
  ## COMMUNES
  ## --------

  resources :communes, module: :communes, only: [] do
    controller :pages do
      get :premiere_visite
    end
    resource :completion, only: %i[new create show]
    resources :objets, only: %i[index show] do
      resources :recensements, only: %i[create edit update destroy] do
        resources :photos, only: %i[create destroy], controller: "recensement_photos"
      end
    end
    resource :dossier, only: [:show]
    resources :campaign_recipients, only: [:update]
    resources :messages, only: %i[index new create] do
      resources :email_attachments, only: [:show]
    end
    resource :user, only: [:update]
  end

  ## -------------
  ## CONSERVATEURS
  ## -------------

  namespace :conservateurs do
    resources :departements, only: %i[index show] do
      resources :campaigns, only: %i[new]
    end
    resources :communes, only: [:show] do
      collection do
        post :autocomplete
      end
      resources :messages, only: %i[index new create] do
        resources :email_attachments, only: [:show]
      end
      resource :dossier, only: %i[show]
      resources :bordereaux, only: %i[new create]
    end
    resources :objets, only: [] do
      resources :recensements, only: [] do
        resource :analyse, only: %i[edit update]
      end
    end
    resources :dossiers, only: [] do
      resource :accept, only: %i[new create update]
    end
    resources :campaigns, except: %i[new index] do
      get :edit_recipients
      patch :update_recipients
      patch :update_status
      get :mail_previews
      resources :recipients, controller: "campaign_recipients", only: %i[show update] do
        get :mail_preview
      end
    end
    resource :conservateur, only: [:update]
    resources :visits, only: [:index]
  end

  ## -----
  ## ADMIN
  ## -----

  namespace :admin do
    resources :communes, only: %i[index show]
    resources :conservateurs, except: [:destroy] do
      get :impersonate
      collection do
        post :toggle_impersonate_mode
      end
    end
    resources :dossiers, only: [:update]
    resources :users, only: %i[new create edit update] do
      get :impersonate
      collection do
        post :toggle_impersonate_mode
      end
    end
    resources :campaigns do
      get :edit_recipients
      patch :update_recipients
      patch :update_status
      get :mail_previews
      if Rails.configuration.x.environment_specific_name != "production"
        post :force_start
        post :force_step_up
        post :update_all_recipients_emails
      end
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
    resources :attachments, only: [:destroy] do
      post :rotate
      put :exportable
    end
    resources :messages, only: [:create] do
      resources :email_attachments, only: [:show]
    end
  end

  # -----
  # API
  # -----

  namespace :api do
    namespace :v1 do
      resources :inbound_emails, only: [:create]
    end
  end

  # ------
  # DEMOS
  # ------

  get "demos/:namespace/:name", to: "demos#show", as: :demo

  # --------------
  # HEALTH & DEBUG
  # --------------

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
  get "health/js_error", to: "health#js_error"
  get "health/slow_image", to: "health#slow_image" if Rails.env.development?

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  resources :mail_previews, only: [:index] if Rails.configuration.x.environment_specific_name != "production"
end

# rubocop:enable Metrics/BlockLength
