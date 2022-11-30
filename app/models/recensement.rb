# frozen_string_literal: true

class Recensement < ApplicationRecord
  include Recensements::AnalyseConcern
  include Recensements::BooleansConcern

  belongs_to :objet
  belongs_to :user
  belongs_to :dossier
  has_many_attached :photos do |attachable|
    attachable.variant :medium, resize_to_limit: [800, 800]
  end

  delegate :commune, to: :objet
  delegate :departement, to: :objet

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

  validates :objet_id, uniqueness: true

  validates :confirmation_sur_place, inclusion: { in: [true] }
  validates :localisation, presence: true, inclusion: { in: LOCALISATIONS }
  validates :edifice_nom, presence: true, if: -> { autre_edifice? }
  validates :recensable, inclusion: { in: [true, false] }, unless: -> { absent? }
  validates :recensable, inclusion: { in: [false] }, if: -> { absent? }
  validates :etat_sanitaire_edifice, presence: true, if: -> { recensable? }
  validates :etat_sanitaire, presence: true, inclusion: { in: ETATS }, if: -> { recensable? }
  validates :securisation, presence: true, inclusion: { in: SECURISATIONS }, if: -> { recensable? }

  validates :etat_sanitaire_edifice, inclusion: { in: [nil] }, if: -> { !recensable? }
  validates :etat_sanitaire, inclusion: { in: [nil] }, if: -> { !recensable? }
  validates :securisation, inclusion: { in: [nil] }, if: -> { !recensable? }
  validates :photos, inclusion: { in: [] }, if: -> { !recensable? && photos.attached? }
  validates :confirmation_pas_de_photos, inclusion: { in: [nil, false] }, if: -> { photos.attached? }

  validates(
    :photos,
    if: -> { recensable? && !confirmation_pas_de_photos },
    attached: true,
    content_type: ["image/jpg", "image/jpeg", "image/png"],
    size: { less_than: 20.megabytes }
  )

  validates :conservateur_id, presence: true, if: -> { analysed? }

  after_create { RefreshCommuneRecensementRatioJob.perform_async(commune.id) }
  after_destroy { RefreshCommuneRecensementRatioJob.perform_async(commune.id) }

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

  SQL_ORDER_PRIORITE = <<-SQL.squish
    CASE WHEN (
      recensements.localisation = 'absent'
      OR (recensements.etat_sanitaire IN ('mauvais', 'peril') AND recensements.analyse_etat_sanitaire IS NULL)
      OR recensements.analyse_etat_sanitaire IN ('mauvais', 'peril')
    ) THEN 0
    ELSE 1
    END
  SQL
  scope :order_by_priorite, -> { order(Arel.sql(SQL_ORDER_PRIORITE)) }
  def self.order_by_priorite_array(recensements_arel)
    recensements_arel.to_a.sort_by { prioritaire? ? 0 : 1 }
  end

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

  def analysable?
    commune.completed?
  end

  def first?
    commune.recensements.empty?
  end
end
