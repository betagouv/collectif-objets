# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper :messages, :user
  layout "user_mailer"
  default to: -> { @user.email }

  def validate_email
    @user = params[:user]
    @login_url = users_sign_in_with_token_url(login_token: @user.login_token)
    mail subject: "Collectif Objets - Votre lien de connexion"
  end

  def commune_completed_email
    @user, @commune = params.values_at(:user, :commune)
    set_login_url
    mail subject: "#{@commune.nom}, merci dʼavoir contribué à Collectif Objets"
  end

  def commune_avec_objets_verts
    @user, @commune = params.values_at(:user, :commune)
    mail subject: ""
  end

  def dossier_accepted_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    @user = @commune.users.first
    @conservateur = @dossier.conservateur || params[:conservateur]
    set_login_url
    mail \
      subject: "Rapport de recensement des objets protégés de #{@commune.nom}",
      from: email_address_with_name("collectifobjets@beta.gouv.fr", @conservateur.to_s),
      reply_to: @conservateur.email
  end

  def dossier_auto_submitted_email
    @user = params[:user]
    @commune = params[:commune]
    set_login_url
    mail subject: "Vos recensements d'objets ont été transmis aux conservateurs"
  end

  def message_received_email
    @message, @user = params.values_at(:message, :user)
    @author = @message.author
    @commune = @message.commune
    set_login_url
    mail \
      reply_to: email_address_with_name(@commune.support_email(role: :user), "Collectif Objets Messagerie"),
      subject: "#{@author} vous a envoyé un message sur Collectif Objets"
  end

  protected

  def set_login_url
    @login_url =
      if @user.magic_token.present?
        magic_authentication_url("magic-token" => @user.magic_token)
      else
        new_user_session_url
      end
  end
end
