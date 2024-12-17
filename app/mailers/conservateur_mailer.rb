# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  layout "conservateur_mailer"
  helper :messages
  helper :commune

  def message_received_email
    @message, @conservateur = params.values_at(:message, :conservateur)
    @commune = @message.commune
    mail subject: "#{@commune.nom} vous a envoyé un message",
         to: email_address_with_name(@conservateur.email, @conservateur.full_name),
         from: email_address_with_name(@commune.support_email(role: :conservateur), "#{@commune} via Collectif Objets")
  end

  def activite_email
    @conservateur = Conservateur.find(params[:conservateur_id])
    @departement = Departement.find(params[:departement_code])
    date_start, date_end = params.values_at(:date_start, :date_end)
    date_range = date_start..date_end
    @human_date_start = l date_start.to_date, format: :long_with_weekday
    @human_date_end = l date_end.to_date, format: :long_with_weekday
    @communes_with_messages = @departement.commune_messages_count(date_range)
    @communes_with_dossiers = @departement.commune_dossiers_transmis(date_range)
    mail \
      to: email_address_with_name(@conservateur.email, @conservateur.full_name),
      subject: "Récapitulatif d'activité du #{@human_date_start} au #{@human_date_end} #{@departement.dans_nom}"
  end
end
