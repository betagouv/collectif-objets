# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  layout "conservateur_mailer"
  helper :messages

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
