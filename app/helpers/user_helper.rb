# frozen_string_literal: true

module UserHelper
  def user_mailer_unsubscribe_url(user)
    after_sign_in_path = "/users/edit"
    if user.magic_token.present?
      magic_authentication_url("magic-token": user.magic_token, after_sign_in_path:)
    else
      new_user_session_url(after_sign_in_path:)
    end
  end
end
