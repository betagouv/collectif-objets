Rails.application.routes.draw do
  root "pages#home"

  resources :objets, only: [:index]
end
