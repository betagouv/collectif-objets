# frozen_string_literal: true

class BroadcastDossierRapportUpdateJob
  include Sidekiq::Job

  def perform(dossier_id)
    Dossier.find(dossier_id).broadcast_replace_later_to(
      Dossier.find(dossier_id),
      "rapport-pdf-embed-and-form",
      target: "js-rapport-pdf-embed-and-form-#{dossier_id}",
      partial: "conservateurs/accepts/form"
    )
  end
end
