# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def new
      @success = params[:success] == "true"
      @error = params[:error]
      super
    end

    def sign_in(user)
      return super if user.mairie?

      redirect_to root_path, flash: { alert: "Impossible de se connecter avec un compte d'administrateur" }
      false
    end

    def sign_in_with_token
      user = User.find_by(login_token: params[:login_token])

      if user.present?
        user.update!(last_sign_in_at: Time.now, login_token: nil, login_token_valid_until: 1.year.ago)
        return unless sign_in(user)

        redirect_to root_path, notice: "Vous êtes maintenant connecté(e)"
      else
        flash[:alert] = "Erreur lors de votre connexion, veuillez réessayer"
        redirect_to new_user_session_path
      end
    end

    def sign_in_with_magic_token
      # the magic token is never rotated
      user = User.find_by(magic_token: params["magic-token"])
      if user.present?
        user.update!(last_sign_in_at: Time.now)
        return unless sign_in(user)

        redirect_to root_path, notice: "Vous êtes maintenant connecté(e)"
      else
        flash[:alert] = "Erreur lors de votre connexion, veuillez réessayer"
        redirect_to new_user_session_path
      end
    end
  end
end
