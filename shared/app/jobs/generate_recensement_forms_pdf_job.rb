# frozen_string_literal: true

class GenerateRecensementFormsPdfJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(commune_id)
    @commune_id = commune_id
    commune.recensement_forms_pdf&.purge
    prawn_view.render_file "hello.pdf"
    commune.recensement_forms_pdf.attach(io: file_io, filename:, content_type: "application/pdf")
    commune.update!(recensement_forms_pdf_updated_at: Time.zone.now)
    # BroadcastDossierRapportUpdateJob.perform_in(0.5.seconds, dossier.id)
  end

  private

  def commune
    @commune ||= Commune.find(@commune_id)
  end

  def prawn_view
    @prawn_view ||= Co::Pdf::RecensementForms::PrawnView.new(commune)
  end

  def filename
    @filename ||= "collectif-objets-recensements-#{commune.code_insee}.pdf"
  end

  def file_io
    StringIO.new(prawn_view.render)
  end
end
