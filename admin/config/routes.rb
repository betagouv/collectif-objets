Rails.application.routes.draw do
  root "pages#home"
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }
  authenticate :user, ->(user) { user.admin? } do
    mount Avo::Engine, at: "/admin"
  end
end
