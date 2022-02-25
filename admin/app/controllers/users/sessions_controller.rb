# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def create
      if !User.find_by_email(params.dig(:user, :email))&.admin?
        return redirect_to root_path, flash: {alert: "Votre compte n'a pas accès à l'interface d'administration"}
      end
      super
    end
  end
end
