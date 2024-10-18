# frozen_string_literal: true

class GenerateBordereauPdfJob < ApplicationJob
  discard_on StandardError, Exception

  def perform(dossier_id, edifice_id)
    dossier = Dossier.find(dossier_id)
    edifice = Edifice.find(edifice_id)
    raise unless edifice.commune == dossier.commune
    # raise unless edifice.objets.classés.count.positive?
    raise unless dossier.accepted?

    pdf = Bordereau::Pdf.new(dossier, edifice)
    edifice.bordereau.attach \
      io: pdf.to_io,
      filename: pdf.filename,
      content_type: Mime[:pdf]
  end
end
