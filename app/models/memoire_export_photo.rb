# frozen_string_literal: true

class MemoireExportPhoto
  COLS = %w[LBASE REF REFIMG NUMP DATPV COULEUR OBS COM DOM EDIF COPY TYPDOC IDPROD LIEUCOR
            LEG TECHOR SCLE INSEE].freeze

  attr_reader :attachment, :recensement, :annee_versement

  def initialize(attachment:, recensement:, annee_versement: nil)
    @attachment = attachment
    raise ArgumentError, "missing attachment" if @attachment.nil?

    @recensement = recensement
    raise ArgumentError, "missing recensement" if @recensement.nil?

    @annee_versement = annee_versement || Time.zone.today.year
  end

  def self.from_attachments(attachments_arel, annee_versement: nil)
    attachments = attachments_arel.to_a
    raise if (attachments.pluck(:record_type) - ["Recensement"]).any?

    map = Recensement.where(id: attachments.pluck(:record_id)).to_a.index_by(&:id)
    attachments.map { new(attachment: _1, recensement: map.fetch(_1.record_id), annee_versement:) }
  end

  def self.from_recensements(recensements_arel, annee_versement: nil)
    recensements_arel
      .includes(:photos_attachments, :photos_blobs)
      .map do |recensement|
        recensement.photos.where(exportable: true).map do |attachment|
          MemoireExportPhoto.new(attachment:, recensement:, annee_versement:)
        end
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
      annee_versement,
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

  def memoire_LEG = recensement.objet.palissy_TICO
  def memoire_TECHOR = recensement.objet.palissy_CATE
  def memoire_SCLE = recensement.objet.palissy_SCLE
  def memoire_INSEE = recensement.objet.palissy_INSEE
  # rubocop:enable Naming/MethodName
end
