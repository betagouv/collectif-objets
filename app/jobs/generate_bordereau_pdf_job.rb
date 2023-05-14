# frozen_string_literal: true

class GenerateBordereauPdfJob
  include Sidekiq::Job

  # do not retry
  sidekiq_options retry: false

  def perform(dossier_id, edifice_id)
    dossier = Dossier.find(dossier_id)
    edifice = Edifice.find(edifice_id)
    raise unless edifice.commune == dossier.commune
    raise unless edifice.objets.classés.count.positive?
    raise unless dossier.accepted?

    prawn_doc = Bordereau::Pdf.new(dossier, edifice).build_prawn_doc
    edifice.bordereau.attach \
      io: StringIO.new(prawn_doc.render),
      filename: "bordereau-#{dossier.commune.to_s.parameterize}-#{edifice.nom.parameterize}.pdf",
      content_type: "application/pdf"
    edifice.broadcast_replace_to \
      edifice,
      target: "bordereau-#{edifice.id}",
      partial: "conservateurs/bordereaux/edifice",
      locals: { edifice:, commune: dossier.commune }
  end
end
