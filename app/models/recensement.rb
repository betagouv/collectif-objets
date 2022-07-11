# frozen_string_literal: true

class Recensement < ApplicationRecord
  include Recensements::AnalyseConcern

  belongs_to :objet
  belongs_to :user
  belongs_to :dossier
  has_many_attached :photos do |attachable|
    attachable.variant :medium, resize_to_limit: [800, 800]
  end

  delegate :commune, to: :objet

  LOCALISATION_EDIFICE_INITIAL = "edifice_initial"
  LOCALISATION_AUTRE_EDIFICE = "autre_edifice"
  LOCALISATION_ABSENT = "absent"
  LOCALISATIONS = [LOCALISATION_EDIFICE_INITIAL, LOCALISATION_AUTRE_EDIFICE, LOCALISATION_ABSENT].freeze

  ETAT_BON = "bon"
  ETAT_MOYEN = "moyen"
  ETAT_MAUVAIS = "mauvais"
  ETAT_PERIL = "peril"
  ETATS = [ETAT_BON, ETAT_MOYEN, ETAT_MAUVAIS, ETAT_PERIL].freeze

  SECURISATION_CORRECTE = "en_securite"
  SECURISATION_MAUVAISE = "en_danger"
  SECURISATIONS = [SECURISATION_CORRECTE, SECURISATION_MAUVAISE].freeze

  validates :localisation, presence: true, inclusion: { in: LOCALISATIONS }
  validates :edifice_nom, presence: true, if: -> { autre_edifice? }
  validates :recensable, inclusion: { in: [true, false] }, unless: -> { absent? }
  validates :recensable, inclusion: { in: [false] }, if: -> { absent? }
  validates :etat_sanitaire_edifice, presence: true, if: -> { !absent? && recensable? }
  validates :etat_sanitaire, presence: true, inclusion: { in: ETATS }, if: -> { !absent? && recensable? }
  validates :securisation, presence: true, inclusion: { in: SECURISATIONS }, if: -> { !absent? && recensable? }
  validates(
    :photos,
    presence: true,
    if: -> { !absent? && recensable? && !skip_photos },
    blob: {
      content_type: ["image/jpg", "image/jpeg", "image/png"],
      size_range: 0..(20.megabytes)
    }
  )

  after_create { RefreshCommuneRecensementRatioJob.perform_async(commune.id) }
  after_create_commit :set_commune_dossier
  after_destroy { RefreshCommuneRecensementRatioJob.perform_async(commune.id) }

  attr_accessor :confirmation, :skip_photos

  scope :present_and_recensable, lambda {
    where(
      recensable: true,
      localisation: [LOCALISATION_EDIFICE_INITIAL, LOCALISATION_AUTRE_EDIFICE]
    )
  }
  scope :missing_photos, lambda {
    present_and_recensable.where.missing(:photos_attachments)
  }
  scope :photos_presence_in, ->(presence) { presence ? all : missing_photos }
  scope :absent, -> { where(localisation: LOCALISATION_ABSENT) }
  scope :recensable, -> { where(recensable: true) }
  scope :not_recensable, -> { where.not(recensable: true) }
  scope :in_departement, lambda { |departement|
    joins(objet: [:commune]).where(communes: { departement: })
  }
  scope :in_commune, ->(commune) { joins(:objet).where(objets: { commune: }) }
  scope :not_analysed, -> { where(analysed_at: nil) }

  accepts_nested_attributes_for :dossier

  def self.ransackable_scopes(_auth_object = nil)
    [:photos_presence_in]
  end

  def self.etats_sanitaires_value_counts
    group("etat_sanitaire")
      .select("etat_sanitaire, count(recensements.id) as recensements_count")
      .map { [_1.etat_sanitaire, _1.recensements_count] }
      .to_h
  end

  def self.possible_values_for(attribute_name)
    if attribute_name.include?("etat_sanitaire")
      ETATS
    elsif attribute_name.include?("securisation")
      SECURISATIONS
    end
  end

  def absent?
    localisation == LOCALISATION_ABSENT
  end

  def autre_edifice?
    localisation == LOCALISATION_AUTRE_EDIFICE
  end

  def edifice_initial?
    localisation == LOCALISATION_EDIFICE_INITIAL
  end

  def editable?
    commune.objets_recensable?
  end

  def missing_photos?
    recensable? && (edifice_initial? || autre_edifice?) && photos.empty?
  end

  def en_peril?
    [analyse_etat_sanitaire, etat_sanitaire].compact.first == ETAT_PERIL
  end

  def set_commune_dossier
    commune.update!(dossier:) if commune.dossier.nil?
  end
end
