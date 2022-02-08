# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def sign_in_with_token
      user = User.find_by(login_token: params[:login_token])

      if user.present?
        user.update(login_token: nil, login_token_valid_until: 1.year.ago)
        sign_in(user)
        redirect_to root_path
      else
        flash[:alert] = "Erreur lors de votre connexion, veuillez réessayer"
        redirect_to new_user_session_path
      end
    end
  end
end
