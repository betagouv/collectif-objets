# frozen_string_literal: true

class ConservateurMailer < ApplicationMailer
  def commune_recompleted_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    @conservateur = @dossier.conservateur
    mail(
      to: @dossier.conservateur.email,
      subject: I18n.t("conservateur_mailer.commune_recompleted.subject", nom_commune: @commune.nom)
    )
  end
end
