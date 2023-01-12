# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  helper :messages

  def commune_recompleted_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    @conservateur = @dossier.conservateur
    mail(
      to: @dossier.conservateur.email,
      subject: I18n.t("conservateur_mailer.commune_recompleted.subject", nom_commune: @commune.nom)
    )
  end

  def message_received_email
    @message = params[:message]
    @conservateur = params[:conservateur]
    @commune = @message.commune
    mail(
      to: @conservateur.email,
      reply_to: email_address_with_name(@commune.support_email(role: :conservateur), "Collectif Objets Messagerie"),
      subject: I18n.t("conservateur_mailer.message_received.subject", nom_commune: @commune.nom)
    )
  end
end
