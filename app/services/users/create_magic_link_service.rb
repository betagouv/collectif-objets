# frozen_string_literal: true

module Users
  class CreateMagicLinkService
    def initialize(email)
      @email = email
    end

    def perform
      return { success: false, error: :no_user_found } if user.nil?

      return { success: false, error: :rotate_failed } unless user&.rotate_login_token

      UserMailer.validate_email(user).deliver_now
      { success: true, error: nil }
    end

    protected

    def user
      @user ||= User.find_by(email: @email)
    end
  end
end
