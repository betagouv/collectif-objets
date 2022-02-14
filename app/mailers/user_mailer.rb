# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def validate_email(user)
    @user = user
    @login_url = sign_in_with_token_url(login_token: @user.login_token)
    mail to: @user.email, subject: "Collectif Objets - Votre lien de connexion"
  end
end
