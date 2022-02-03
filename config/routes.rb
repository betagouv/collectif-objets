Rails.application.routes.draw do
  root "pages#home"

  resources :objets, only: [:index, :show]
  resources :communes, only: [:index]
end
