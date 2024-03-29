# frozen_string_literal: true

class GenerateBordereauPdfJob < ApplicationJob
  discard_on StandardError, Exception

  def perform(dossier_id, edifice_id)
    dossier = Dossier.find(dossier_id)
    edifice = Edifice.find(edifice_id)
    raise unless edifice.commune == dossier.commune
    # raise unless edifice.objets.classés.count.positive?
    raise unless dossier.accepted?

    prawn_doc = Bordereau::Pdf.new(dossier, edifice).build_prawn_doc
    edifice.bordereau.attach \
      io: StringIO.new(prawn_doc.render),
      filename: "bordereau-#{dossier.commune.to_s.parameterize}-#{edifice.nom.parameterize}.pdf",
      content_type: "application/pdf"
  end
end
