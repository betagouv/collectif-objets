# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper :messages
  layout "user_mailer"
  default to: -> { @user.email }

  def session_code_email
    @session_code = params[:session_code]
    @user = @session_code.user
    mail subject: "Collectif Objets - Code de connexion - envoyé à #{I18n.l(Time.zone.now, format: :time_first)} " \
  end

  def commune_completed_email
    @user, @commune = params.values_at(:user, :commune)
    @cta_url = commune_completion_url(@commune)
    mail subject: "#{@commune.nom}, merci dʼavoir contribué à Collectif Objets"
  end

  def commune_avec_objets_verts_email
    @user, @commune = params.values_at(:user, :commune)
    mail subject: "Suite à votre participation à la campagne de recensement " \
                  "des objets monuments historique #{@commune.departement.dans_nom}"
  end

  def dossier_accepted_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    @user = @commune.users.first
    @conservateur = @dossier.conservateur || params[:conservateur]
    @cta_url = commune_dossier_url(@commune)
    mail \
      subject: "Examen du recensement des objets protégés de #{@commune.nom}",
      from: email_address_with_name("collectifobjets@beta.gouv.fr", @conservateur.to_s),
      reply_to: @conservateur.email
  end

  def dossier_auto_submitted_email
    @user = params[:user]
    @commune = params[:commune]
    @cta_url = commune_completion_url(@commune)
    set_login_url
    mail subject: "Vos recensements d'objets ont été transmis aux conservateurs"
  end

  def message_received_email
    @message, @user = params.values_at(:message, :user)
    @author = @message.author
    @commune = @message.commune
    @cta_url = commune_messages_url(@commune)
    mail \
      reply_to: email_address_with_name(@commune.support_email(role: :user), "Collectif Objets Messagerie"),
      subject: "#{@author} vous a envoyé un message sur Collectif Objets"
  end

  protected

  def set_login_url
    @login_url = new_user_session_code_url
  end
end
