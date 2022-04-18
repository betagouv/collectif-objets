# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  def commune_recompleted_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    mail(
      to: @dossier.conservateur.email,
      subject: "#{@commune.nom} vous a retourné le dossier de recensement"
    )
  end
end
