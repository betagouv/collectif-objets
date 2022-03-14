require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root "admin/communes#index"

  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end
end
