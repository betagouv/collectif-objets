# frozen_string_literal: true

class MemoireExportPhoto
  COLS = %w[LBASE REF REFIMG NUMP DATPV COULEUR OBS COM DOM EDIF COPY TYPDOC IDPROD LIEUCOR].freeze

  attr_reader :attachment, :recensement

  def initialize(attachment:, recensement:)
    @attachment = attachment
    @recensement = recensement
  end

  def self.from_attachments(attachments)
    raise if (attachments.pluck(:record_type) - ["Recensement"]).any?

    map = Recensement.where(id: attachments.pluck(:record_id)).to_a.index_by(&:id)
    attachments.map { new(attachment: _1, recensement: map[_1.record_id]) }
  end

  def self.from_recensements(recensements_arel)
    recensements_arel
      .includes(:photos_attachments, :photos_blobs)
      .map do |recensement|
        recensement.photos.map { MemoireExportPhoto.new(attachment: _1, recensement:) }
      end.flatten
  end

  def cols_values
    COLS.map { send("memoire_#{_1}") }
  end

  # rubocop:disable Naming/MethodName
  def memoire_LBASE = ""

  def memoire_REF
    [
      "MHCO",
      recensement.departement.code.rjust(3, "0"),
      "_",
      memoire_DATPV,
      memoire_NUMP
    ].join
  end

  def memoire_REFIMG
    "#{memoire_REF}.#{attachment.send('file_extension')}"
  end

  def memoire_DATPV
    attachment.created_at.year
  end

  def memoire_NUMP
    attachment.memoire_number.to_s.rjust(6, "0")
  end

  def memoire_COULEUR = "Oui"

  def memoire_OBS = "Photographie fournie lors du recensement réalisé par Collectif Objets"

  def memoire_COM = recensement.commune.nom

  def memoire_DOM = "objet"

  def memoire_EDIF = recensement.objet.edifice.nom

  def memoire_COPY = "© Ministère de la Culture (France), Collectif Objets – Tous droits réservés"

  def memoire_TYPDOC = "Image numérique native"

  def memoire_IDPROD = "MHCO008"

  def memoire_LIEUCOR = "Collectif Objets"
  # rubocop:enable Naming/MethodName
end
