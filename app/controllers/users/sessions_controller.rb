# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    prepend_before_action :require_no_authentication, only: %i[new sign_in_with_token sign_in_with_magic_token]

    def new
      @success = params[:success] == "true"
      @error = params[:error]
      super
    end

    def sign_in_with_token
      user = User.find_by(login_token: params[:login_token])

      if user.present?
        user.update!(last_sign_in_at: Time.zone.now, login_token: nil, login_token_valid_until: 1.year.ago)
        return unless sign_in(user)

        redirect_to after_sign_in_path_for(user), notice: "Vous êtes maintenant connecté(e)"
      else
        flash[:alert] = "Erreur lors de votre connexion, veuillez réessayer"
        redirect_to new_user_session_path
      end
    end

    def sign_in_with_magic_token
      # the magic token is never rotated
      user = User.find_by(magic_token: params["magic-token"])
      if user.present?
        user.update!(last_sign_in_at: Time.zone.now)
        return unless sign_in(user)

        redirect_to after_sign_in_path_for(user), notice: "Vous êtes maintenant connecté(e)"
      else
        flash[:alert] = "Erreur lors de votre connexion, veuillez réessayer"
        redirect_to new_user_session_path
      end
    end

    def require_no_authentication
      super

      resource_name = "conservateur"
      resource = warden.user(resource_name)
      return unless warden.authenticated?(resource_name) && resource

      set_flash_message(:alert, "already_authenticated", scope: "devise.failure")
      redirect_to after_sign_in_path_for(resource)
    end
  end
end
