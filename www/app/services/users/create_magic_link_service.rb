# frozen_string_literal: true

module Users
  class CreateMagicLinkService
    def initialize(email)
      @email = email
    end

    def perform
      return { success: false, error: :no_user_found } if user_or_conservateur.nil?

      return { success: false, error: :rotate_failed } unless user_or_conservateur&.rotate_login_token

      UserMailer.validate_email(user_or_conservateur).deliver_now
      { success: true, error: nil }
    end

    protected

    def user_or_conservateur
      @user_or_conservateur ||= find_user_or_conservateur
    end

    def find_user_or_conservateur
      if @email.match(Conservateur::EMAIL_REGEX)
        Conservateur.find_by(email: @email)
      else
        User.find_by(email: @email)
      end
    end
  end
end
