# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def validate_email(user)
    @user = user
    mail to: @user.email, subject: "Collectif Objets - Votre lien de connexion"
  end
end
