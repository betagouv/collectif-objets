# frozen_string_literal: true

class ConservateurMailerPreview < ApplicationMailerPreview
  def message_received_email
    message = Message.from_commune.first
    conservateur = Message.from_conservateur.first.author

    ConservateurMailer.with(message:, conservateur:).message_received_email
  end

  def activite_email
    departement = Departement.joins(:conservateurs, :dossiers).where.not(dossiers: { submitted_at: nil }).first
    conservateur_id = departement.conservateur_ids.first
    date_start = departement.dossiers.submitted.first.submitted_at.at_beginning_of_week
    date_end = date_start + 6.days

    ConservateurMailer.with(conservateur_id:, departement_code: departement.code, date_start:, date_end:).activite_email
  end
end
