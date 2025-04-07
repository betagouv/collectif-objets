# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    prepend_before_action :require_no_authentication, only: %i[new create redirect_from_magic_token]
    before_action :redirect_with_devise_return_to, only: %i[new]
    before_action :set_email_user_and_commune, only: %i[new create]

    def new; end

    def create
      @user, @error = User.authenticate_by(**params.permit(:email, :code).to_h.symbolize_keys)
      if @user && sign_in(@user)
        redirect_to after_sign_in_path_for(@user), notice: "Vous êtes maintenant connecté(e)"
      else
        render :new, status: :unprocessable_content
      end
    end

    def redirect_from_magic_token
      user = User.find_by(magic_token_deprecated: params["magic-token"])
      if user.present?
        redirect_to(
          new_user_session_code_path(code_insee: user.commune.code_insee),
          alert: "ce lien de connexion n’est plus valide"
        )
      else
        redirect_to new_user_session_code_path, alert: "ce lien de connexion n’est plus valide"
      end
    end

    private

    def redirect_with_devise_return_to
      return true if params[:email].present?

      match_data = session["user_return_to"]&.match(%r{^/communes/(\d+)/})
      commune = match_data && Commune.find(match_data[1].to_i)
      redirect_to new_user_session_code_path(code_insee: commune&.code_insee) if commune
    end

    def set_email_user_and_commune
      @email = params[:email]
      return redirect_to new_user_session_code_path if @email.blank?

      @user = User.find_by(email: @email)
      if @user.blank?
        return redirect_to new_user_session_code_path,
                           alert: "Aucune commune associée à l'email #{@email}"
      end

      @commune = @user.commune
    end
  end
end
