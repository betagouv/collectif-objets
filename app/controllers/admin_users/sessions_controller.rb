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

      if user.validate_and_consume_otp!(params[:admin_user][:otp_attempt])
        sign_in(user)
        set_flash_message!(:notice, :signed_in)
        redirect_to after_sign_in_path_for(user)
      else
        self.resource = user
        flash.now[:alert] = "Code 2FA #{otp.blank? ? 'requis' : 'invalide'}"
        render :new, status: :unprocessable_entity
      end
    end

    def find_user
      return unless (email = params.dig(:admin_user, :email))

      AdminUser.find_by(email:)
    end

    def otp = params.dig(:admin_user, :otp_attempt)
  end
end
