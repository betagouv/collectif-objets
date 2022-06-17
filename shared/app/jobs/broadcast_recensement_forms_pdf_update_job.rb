# frozen_string_literal: true

class BroadcastRecensementFormsPdfUpdateJob
  include Sidekiq::Job

  def perform(commune_id)
    @commune_id = commune_id
    commune.broadcast_replace_to(
      commune,
      "recensement-forms-pdf-download",
      target: "js-recensement-forms-pdf-download-commune-#{commune.id}",
      html: ApplicationController.render(
        Communes::RecensementFormsPdfDownloadComponent.new(commune),
        layout: false
      )
    )
  end

  private

  def commune
    @commune ||= Commune.find(@commune_id)
  end
end
