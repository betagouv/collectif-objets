# frozen_string_literal: true

module AdminUsers
  class SessionsController < Devise::SessionsController
    prepend_before_action :authenticate_with_otp_two_factor, if: -> { params[:admin_user].present? }

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt])
    end

    def after_sign_in_path_for(resource)
      return admin_admin_user_two_factor_settings_path(resource) unless resource.otp_required_for_login?

      super
    end

    private

    def authenticate_with_otp_two_factor
      user = find_user
      return unless user&.otp_required_for_login?

      otp_code = params.require(:admin_user).permit(:otp_attempt)[:otp_attempt]

      if authenticate_with_otp(user, otp_code)
        sign_in_and_redirect(user, notice: "Connexion réussie")
      elsif authenticate_with_backup_code(user, otp_code)
        sign_in_and_redirect(user, warning: backup_code_warning_message(user))
      else
        handle_failed_authentication(user, otp_code)
      end
    end

    def authenticate_with_otp(user, otp_code)
      user.validate_and_consume_otp!(otp_code)
    end

    def authenticate_with_backup_code(user, otp_code)
      user.invalidate_otp_backup_code!(otp_code)
    end

    def sign_in_and_redirect(user, notice: nil, warning: nil)
      sign_in(user)
      set_flash_message!(:notice, :signed_in) if notice
      flash[:alert] = warning if warning
      redirect_to after_sign_in_path_for(user)
    end

    def backup_code_warning_message(user)
      remaining = user.otp_backup_codes_remaining
      if remaining.zero?
        "Connecté avec un code de secours. C'était votre dernier code ! Générez-en de nouveaux."
      else
        "Connecté avec un code de secours. Il vous reste #{pluralize(remaining, 'code')}."
      end
    end

    def handle_failed_authentication(user, otp_code)
      self.resource = user
      flash.now[:alert] = "Code d'authentification à deux facteurs #{otp_code.blank? ? 'requis' : 'invalide'}"
      render :new, status: :unprocessable_entity
    end

    def find_user
      return unless (email = params.dig(:admin_user, :email))

      AdminUser.find_by(email:)
    end

    def otp = params.dig(:admin_user, :otp_attempt)
  end
end
