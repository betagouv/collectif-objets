# frozen_string_literal: true

class RecensementPresenterPdf < RecensementPresenter
  def initialize(recensement, prawn_doc)
    @prawn_doc = prawn_doc
    super(recensement)
  end

  def badge(badge_type)
    { type: "badge", badge_type:, content: yield }
  end

  def text
    { type: "text", content: yield }
  end

  def photos
    raise
  end

  def notes
    text { @recensement.notes.presence || "<i>Aucun commentaire</i>" }
  end

  def analyse_notes
    text { @recensement.analyse_notes.presence || "<i>Aucun commentaire</i>" }
  end
end
