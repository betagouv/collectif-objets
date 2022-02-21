# frozen_string_literal: true

module Users
  class MagicLinksController < ApplicationController
    def create
      email = params.dig(:user, :email)
      if email.blank?
        return redirect_to(new_user_session_path, alert: "Veuillez renseigner votre email")
      end

      Users::CreateMagicLinkService.new(email).perform => {success:, error:}

      if success
        flash.notice = "Un lien de connexion valide 1 heure vous a été envoyé"
      elsif error == :no_user_found
        flash.alert = "Aucun compte n'a été trouvé pour l'email #{email}"
      end
      redirect_to(new_user_session_path(user: { email: }, success:, error:))
    end
  end
end
