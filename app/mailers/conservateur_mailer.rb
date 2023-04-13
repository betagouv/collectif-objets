# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  layout "conservateur_mailer"
  helper :messages

  def message_received_email
    @message, @conservateur = params.values_at(:message, :conservateur)
    @commune = @message.commune
    mail \
      to: @conservateur.email,
      reply_to: email_address_with_name(@commune.support_email(role: :conservateur), "Collectif Objets Messagerie"),
      subject: "#{@commune.nom} vous a envoyé un message"
  end
end
