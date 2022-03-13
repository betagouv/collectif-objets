# frozen_string_literal: true

module Users
  class MagicLinksController < ApplicationController
    before_action :prevent_missing_email, :prevent_admin

    def create
      Users::CreateMagicLinkService.new(email).perform => {success:, error:}

      if success
        flash.notice = "Un lien de connexion valide 1 heure vous a été envoyé"
      elsif error == :no_user_found
        flash.alert = "Aucun compte n'a été trouvé pour l'email #{email}"
      end
      redirect_to(new_user_session_path(user: { email: }, success:, error:))
    end

    protected

    def email
      params.dig(:user, :email)
    end

    def user
      @user ||= User.find_by(email:)
    end

    def prevent_admin
      return true if user.nil? || user&.mairie?

      redirect_to(new_user_session_path, alert: "Impossible de se connecter avec un compte d'administrateur")
    end

    def prevent_missing_email
      return true if email.present?

      redirect_to(new_user_session_path, alert: "Veuillez renseigner votre email")
    end
  end
end
