# frozen_string_literal: true

class MagicLink
  def initialize(email)
    @email = email
  end

  def create
    return { success: false, error: :no_user_found } if user.nil?

    return { success: false, error: :rotate_failed } unless user&.rotate_login_token

    UserMailer.with(user:).validate_email.deliver_now
    { success: true, error: nil }
  end

  protected

  def user
    @user ||= User.find_by("email ILIKE ?", @email)
  end
end
