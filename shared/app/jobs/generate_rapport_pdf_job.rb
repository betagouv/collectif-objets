# frozen_string_literal: true

class GenerateRapportPdfJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(dossier_id)
    @dossier_id = dossier_id
    dossier.pdf&.purge
    dossier.update!(pdf_updated_at: Time.zone.now)
    # pdf.render_file "hello.pdf"
    dossier.pdf.attach(io: file_io, filename:, content_type: "application/pdf")
    BroadcastDossierRapportUpdateJob.perform_in(0.5.seconds, dossier.id)
  end

  private

  def dossier
    @dossier ||= Dossier.find(@dossier_id)
  end

  def prawn_view
    @prawn_view ||= Co::Rapports::PrawnView.new(dossier)
  end

  def filename
    @filename ||= "collectif-objets-rapport-recensement-#{dossier.commune.nom.parameterize}-#{dossier.id}.pdf"
  end

  def file_io
    StringIO.new(prawn_view.render)
  end
end
