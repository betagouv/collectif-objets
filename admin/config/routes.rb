Rails.application.routes.draw do
  root "pages#home"
  devise_for :users, :skip => [:registrations], controllers: {
    sessions: "users/sessions",
    passwords: "users/passwords",
  }

  devise_scope :user do
    # we've disabled registrations to avoid sign ups, but we still want editable users
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  authenticate :user, ->(user) { user.admin? } do
    mount Avo::Engine, at: "/admin"
  end
end
