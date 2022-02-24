Rails.application.routes.draw do
  devise_for :users
  authenticate :user, ->(user) { user } do
    mount Avo::Engine, at: "/"
  end
end
