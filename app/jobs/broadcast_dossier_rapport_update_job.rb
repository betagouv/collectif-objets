# frozen_string_literal: true

class BroadcastDossierRapportUpdateJob
  include Sidekiq::Job

  def perform(dossier_id)
    @dossier_id = dossier_id
    dossier.broadcast_replace_to(
      dossier,
      "rapport-pdf-embed-and-form",
      target: "js-accept-preview--#{dossier.id}",
      html: ApplicationController.render(
        Conservateurs::AcceptPreviewComponent.new(dossier:),
        layout: false
      )
    )
  end

  private

  def dossier
    @dossier ||= Dossier.find(@dossier_id)
  end
end
