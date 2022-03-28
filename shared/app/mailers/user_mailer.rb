# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def validate_email(user)
    @user = user
    @login_url = sign_in_with_token_url(login_token: @user.login_token)
    mail to: @user.email, subject: "Collectif Objets - Votre lien de connexion"
  end

  def commune_completed_email
    user = User.find(params[:user_id])
    commune = Commune.find(params[:commune_id])
    @login_url = user_login_url(user)
    mail to: user.email, subject: "#{commune.nom}, merci d'avoir contribué à Collectif Objets"
  end
end
