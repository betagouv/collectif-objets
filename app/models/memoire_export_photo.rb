# frozen_string_literal: true

class MemoireExportPhoto
  COLS = %w[LBASE REF REFIMG NUMP DATPV COULEUR OBS COM DOM EDIF COPY TYPDOC IDPROD LIEUCOR
            LEG TECHOR DATOEU SCLE AUTOEU INSEE ADRESSE LIEU].freeze

  attr_reader :attachment, :recensement, :palissy_objet

  def initialize(attachment:, recensement:, palissy_objet: {})
    @attachment = attachment
    raise ArgumentError, "missing attachment" if @attachment.nil?

    @recensement = recensement
    raise ArgumentError, "missing recensement" if @recensement.nil?

    @palissy_objet = palissy_objet
    raise ArgumentError, "missing palissy_objet" if @palissy_objet.nil?
  end

  def self.from_attachments(attachments_arel)
    attachments = attachments_arel.to_a
    raise if (attachments.pluck(:record_type) - ["Recensement"]).any?

    map = Recensement.where(id: attachments.pluck(:record_id)).to_a.index_by(&:id)
    attachments.map { new(attachment: _1, recensement: map.fetch(_1.record_id)) }
  end

  def self.from_recensements(recensements_arel, palissy_data:)
    recensements_arel
      .includes(:photos_attachments, :photos_blobs)
      .map do |recensement|
        palissy_objet = palissy_data.find { _1["REF"] == recensement.objet.palissy_REF }
        recensement.photos.map { MemoireExportPhoto.new(attachment: _1, recensement:, palissy_objet:) }
      end.flatten
  end

  def cols_values
    COLS.map { send("memoire_#{_1}") }
  end

  # rubocop:disable Naming/MethodName
  def memoire_LBASE = recensement.objet.palissy_REF

  def memoire_REF
    [
      "MHCO",
      recensement.departement.code.rjust(3, "0"),
      "_",
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
    [
      memoire_DATPV,
      recensement.departement.code.rjust(3, "0"),
      attachment.memoire_number.to_s.rjust(6, "0")
    ].join
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

  def memoire_LEG = palissy_objet["TICO"]
  def memoire_TECHOR = palissy_objet["CATE"]&.join(";")
  def memoire_DATOEU = palissy_objet["DATE"]&.join(";")
  def memoire_SCLE = palissy_objet["SCLE"]&.join(";")
  def memoire_AUTOEU = palissy_objet["AUTR"]&.join(";")
  def memoire_INSEE = palissy_objet["INSEE"]
  def memoire_ADRESSE = palissy_objet["ADRS"]
  def memoire_LIEU = palissy_objet["LIEU"]
  # rubocop:enable Naming/MethodName
end
