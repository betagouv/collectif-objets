# frozen_string_literal: true

Rails.application.routes.draw do
  ## -----
  ## DEVISE
  ## -----

  devise_for :admin_users, skip: [:registrations]
  authenticate :admin_user do
    mount GoodJob::Engine => "/good_job"
  end

  devise_for :users, skip: [:registrations], controllers: {
    sessions: "users/sessions"
  }
  devise_scope :user do
    # we've disabled registrations to avoid sign ups, but we still want editable users
    get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
    put "users" => "devise/registrations#update", :as => "user_registration"

    get "magic-authentication", to: "users/sessions#redirect_from_magic_token"
    namespace :users, as: :user do
      resource :session, only: %i[new create destroy]
      resources :session_codes, only: %i[new create]
      resource :unsubscribe, only: %i[new create]
    end
  end

  devise_for :conservateurs, only: %i[sessions passwords]
  devise_scope :conservateur do
    # we've disabled registrations to avoid sign ups, but we still want editable conservateurs
    get "conservateurs/edit" => "devise/registrations#edit", :as => "edit_conservateur_registration"
  end

  direct :annuaire_service_public do |commune|
    if commune.is_a? Commune
      "https://www.service-public.fr/particuliers/recherche?keyword=mairie+#{commune.nom}+#{commune.departement.nom}"
    else
      "https://lannuaire.service-public.fr/navigation/mairie"
    end
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
    get :pdf, to: redirect("guide-de-recensement")
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

  resources :communes, only: :show
  resources :objets, only: [:index, :show]
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
      get :activite, on: :collection, action: :activite_des_departements
      get :carte, on: :member
      get :activite, on: :member
      resources :campaigns, only: %i[new]
    end
    resources :communes, only: [:show] do
      collection do
        post :autocomplete
      end
      resources :messages, only: %i[index new create] do
        resources :email_attachments, only: [:show]
      end
      resource :dossier, only: :show
      get :historique, as: :historique, to: "dossiers#historique"
      resources :bordereaux, only: %i[index create show]
      resource :deleted_recensements, only: [:show]
    end
    resources :objets, only: [] do
      resources :recensements, only: [] do
        resource :analyse, only: %i[edit update]
      end
    end
    resources :dossiers, only: [] do
      resource :accept, only: %i[new create update destroy]
    end
    resources :campaigns, except: %i[new index] do
      get :edit_recipients
      patch :update_recipients
      patch :update_status
      get :mail_previews
      resources :recipients, controller: "campaign_recipients", only: :update do
        get :mail_preview
      end
    end
    resource :conservateur, only: [:update]
    resources :visits, only: [:index]
    resources :fiches, only: :index
    resources :attachments, only: %i[create update destroy]
  end

  ## -----
  ## ADMIN
  ## -----

  namespace :admin do
    resources :communes, only: %i[index show] do
      post :session_code, on: :member
    end
    resources :conservateurs do
      post :impersonate, on: :member
      delete :stop_impersonating, on: :member
      post :toggle_impersonate_mode, on: :collection
    end
    resources :dossiers, only: [:show]
    resources :users, only: %i[] do
      post :impersonate, on: :member
      delete :stop_impersonating, on: :member
      post :toggle_impersonate_mode, on: :collection
    end
    resources :recenseurs
    get "/session_codes(/:offset)", to: "session_codes#index", as: :session_codes
    resources :campaigns do
      get :edit_recipients
      patch :update_recipients
      patch :update_status
      get :mail_previews
      if Rails.configuration.x.environment_specific_name != "production"
        post :force_start
        post :force_step_up
      end
      resources :recipients, controller: "campaign_recipients", only: :update do
        get :mail_preview
      end
      resources :emails, controller: "campaign_emails", only: [] do
        get :redirect_to_sib_preview
      end
    end
    resources :admin_comments, only: %i[create destroy], controller: "comments"
    namespace :exports do
      resources :memoire, except: :edit
      controller :mpp do
        get :deplaces
        get :manquants
      end
    end
    resources :attachments, only: [:destroy] do
      post :rotate
      put :exportable
    end
    resources :messages, only: [:create] do
      resources :email_attachments, only: [:show]
    end
    resources :mail_previews, only: [:index] do
      get "/:mailer/:email", on: :collection, action: :show, as: :preview
    end
    resources :admin_users
  end

  # -----
  # API
  # -----

  namespace :api do
    namespace :v1 do
      resources :inbound_emails, only: [:create]
    end
  end

  # --------------
  # HEALTH & DEBUG
  # --------------

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
  get "health/js_error", to: "health#js_error"
  get "health/slow_image", to: "health#slow_image" if Rails.env.development?
end

# rubocop:enable Metrics/BlockLength
