# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def validate_email
    user = User.new(email: "mairie@thoiry.fr", login_token: "a1r2b95")
    user.readonly!
    UserMailer.validate_email(user)
  end
end
