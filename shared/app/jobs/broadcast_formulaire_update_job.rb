# frozen_string_literal: true

class BroadcastFormulaireUpdateJob
  include Sidekiq::Job

  def perform(commune_id)
    @commune_id = commune_id
    commune.broadcast_replace_to(
      commune,
      "formulaire",
      target: "js-formulaire-commune-#{commune.id}",
      html: ApplicationController.render(
        PdfEmbedComponent.new(commune.formulaire),
        layout: false
      )
    )
  end

  private

  def commune
    @commune ||= Commune.find(@commune_id)
  end
end
