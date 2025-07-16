# frozen_string_literal: true

require "open-uri"

class BordereauRecensement < ApplicationRecord
  belongs_to :bordereau, inverse_of: :bordereau_recensements
  belongs_to :recensement, inverse_of: :bordereau_recensements
  has_one :objet, through: :recensement

  scope :sorted, -> { joins(:objet).order('objets."palissy_EMPL", objets."palissy_TICO"') }

  delegate :objet, :absent?, :recensable?, :analyse_etat_sanitaire, :mauvaise_securisation?, to: :recensement
  delegate :nom, :palissy_DPRO, :palissy_REF, :palissy_SCLE, :palissy_CATE, to: :objet

  class << self
    def etats_sanitaires = human_attribute_name(:etat_sanitaires, count: nil).invert
  end

  def denomination
    [nom, époque, catégorie].compact_blank.join("\n")
  end

  def époque = palissy_SCLE ? palissy_SCLE.split(";").compact_blank.join(", ") : ""
  def catégorie = palissy_CATE ? palissy_CATE.split(";").compact_blank.join(", ") : ""

  def etat_sanitaire = super.presence || etat_sanitaire_recensement

  def etat_sanitaire_recensement
    if absent?
      "introuvable"
    elsif !recensable?
      "non_recensable"
    elsif analyse_etat_sanitaire.present?
      analyse_etat_sanitaire
    else
      recensement.etat_sanitaire
    end
  end

  def recensement_photo
    recensement.photos&.first&.variant(:small)
  end

  def palissy_photo
    objet.palissy_photos.first["url"]&.sub(MEMOIRE_PHOTOS_AWS_BASE_URL, MEMOIRE_PHOTOS_BASE_URL)
  end

  def photo
    recensement_photo&.url || palissy_photo
  end

  def notes_commune
    super || [nouvel_edifice, recensement.notes&.upcase_first].compact_blank.join(" ")
  end

  def notes_conservateur
    super || [facile_à_voler, recensement.analyse_notes&.upcase_first].compact_blank.join(" ")
  end

  def nouvel_edifice
    "L’objet a été déplacé : #{recensement.edifice_nom}." if recensement.deplacement_definitif?
  end

  def facile_à_voler
    "L’objet peut être volé facilement." if recensement.mauvaise_securisation?
  end

  def observations
    [
      "<b>Commune :</b> #{notes_commune.presence}",
      "<b>Conservateur :</b> #{notes_conservateur.presence}",
      "<b>Propriétaire :</b> #{notes_proprietaire.presence}",
      "<b>Affectataire :</b> #{notes_affectataire.presence}"
    ].join("\n")
  end

  def to_pdf_cells
    [
      palissy_REF,
      denomination,
      palissy_DPRO, # date de protection
      etat_sanitaire,
      observations,
      pdf_photo
    ]
  end

  def pdf_photo
    data = if (blob = recensement_photo)
             blob.processed.download
           elsif (url = palissy_photo)
             raise ArgumentError, "Only https urls are allowed" unless url.start_with?("https://")

             URI.open(url, "rb", &:read) # rubocop:disable Security/Open
           end

    { image: StringIO.new(data), fit: [65, 65] } if data
  end
end
