# frozen_string_literal: true

module Conservateurs
  class SessionsController < Devise::SessionsController
    def new
      raise
    end

    def sign_in_with_token
      user = Conservateur.find_by(login_token: params[:login_token])

      if user.present?
        user.update!(last_sign_in_at: Time.zone.now, login_token: nil, login_token_valid_until: 1.year.ago)
        return unless sign_in(user)

        redirect_to after_sign_in_path_for(user), notice: "Vous êtes maintenant connecté(e)"
      else
        flash[:alert] = "Erreur lors de votre connexion, veuillez réessayer"
        redirect_to new_user_session_path
      end
    end
  end
end
