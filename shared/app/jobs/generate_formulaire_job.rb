# frozen_string_literal: true

class GenerateFormulaireJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(commune_id)
    @commune_id = commune_id
    generate
    saved = commune.update(formulaire_updated_at: Time.zone.now)
    raise commune.errors.full_messages.join unless saved

    BroadcastFormulaireUpdateJob.perform_in(0.5.seconds, commune_id)
  end

  private

  def generate
    commune.formulaire&.purge
    commune.formulaire.attach(io: file_io, filename:, content_type: "application/pdf")
  end

  def commune
    @commune ||= Commune.find(@commune_id)
  end

  def prawn_view
    @prawn_view ||= Co::Pdf::Formulaire::PrawnView.new(commune)
  end

  def filename
    @filename ||= "collectif-objets-recensements-#{commune.code_insee}.pdf"
  end

  def file_io
    StringIO.new(prawn_view.render)
  end
end
