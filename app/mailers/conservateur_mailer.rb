# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  layout "conservateur_mailer"
  helper :messages
  helper :commune

  def message_received_email
    @message, @conservateur = params.values_at(:message, :conservateur)
    @commune = @message.commune
    mail \
      to: @conservateur.email,
      reply_to: email_address_with_name(@commune.support_email(role: :conservateur), "Collectif Objets Messagerie"),
      subject: "#{@commune.nom} vous a envoyé un message"
  end

  def activite_email
    @conservateur, @departement = params.values_at(:conservateur, :departement)
    @date_start, @date_end = params.values_at(:date_start, :date_end)
    @human_date_start = l @date_start.to_date, format: :long_with_weekday
    @human_date_end = l @date_end.to_date, format: :long_with_weekday
    @communes_with_messages, @communes_with_dossiers = @departement.activity(@date_start..@date_end)
      .values_at(:commune_messages_count, :commune_dossiers_transmis)
    mail \
      to: email_address_with_name(@conservateur.email, @conservateur.full_name),
      subject: "Récapitlatif d'activité du #{@human_date_start} au #{@human_date_end} #{@departement.dans_nom}"
  end
end
