# frozen_string_literal: true

class Commune < ApplicationRecord
  include Communes::IncludeCountsConcern

  DISPLAYABLE_DEPARTEMENTS = %w[51 52 65 72 26 30].freeze

  include AASM
  aasm(column: :status, timestamps: true) do
    state :inactive, initial: true, display: "Commune inactive"
    state :enrolled, display: "Commune inscrite"
    state :started, display: "Recensement démarré"
    state :completed, display: "Recensement terminé"

    event(:enroll) { transitions from: :inactive, to: :enrolled }
    event(:start) do
      transitions from: :inactive, to: :started
      transitions from: :enrolled, to: :started
    end
    event(:complete) { transitions from: :started, to: :completed }
  end

  has_many :users, dependent: :restrict_with_exception
  has_many(
    :objets,
    foreign_key: :commune_code_insee,
    primary_key: :code_insee,
    inverse_of: :commune,
    dependent: :restrict_with_exception
  )
  has_many :recensements, through: :objets
  has_many :past_dossiers, class_name: "Dossier", dependent: :nullify
  belongs_to :dossier, optional: true

  scope :has_recensements_with_missing_photos, lambda {
    joins(:recensements).merge(Recensement.missing_photos).group(:id)
  }
  scope :recensements_photos_presence_in, lambda { |presence|
    presence ? all : has_recensements_with_missing_photos
  }
  scope :completed, -> { where(status: STATE_COMPLETED) }

  include PgSearch::Model
  pg_search_scope :search_by_nom, against: :nom, using: { tsearch: { prefix: true } }
  accepts_nested_attributes_for :dossier

  def self.ransackable_scopes(_auth_object = nil)
    [:recensements_photos_presence_in]
  end

  # rubocop:disable Metrics/AbcSize
  def self.select_best_objets(objets_arr)
    objets_arr
      .optional_filter { _1.image_urls.any? }
      .optional_filter { _1.nom.exclude?(";") }
      .optional_filter { !_1.nom.match?(/[A-Z]/) }
      .optional_filter { _1.edifice_nom.present? }
      .optional_filter { _1.edifice_nom&.match?(/[A-Z]/) }
      .optional_filter { _1.emplacement.blank? }
  end
  # rubocop:enable Metrics/AbcSize

  def self.status_value_counts
    group(:status)
      .select("status, count(id) as communes_count")
      .map { [_1.status, _1.communes_count] }
      .to_h
  end

  def main_objet
    @main_objet ||=
      Commune.select_best_objets(objets.where.not(nom: nil).to_a).first
  end

  def enrolled_or_started?
    enrolled? || started?
  end

  def objets_recensable?
    !completed? || dossier&.rejected?
  end

  def can_complete?
    enrolled_or_started? && objets.all?(&:recensement?)
  end
end
