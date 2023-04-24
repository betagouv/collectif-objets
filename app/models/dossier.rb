# frozen_string_literal: true

class Dossier < ApplicationRecord
  belongs_to :commune
  has_many :recensements, dependent: :nullify
  has_many :objets, through: :recensements
  belongs_to :conservateur, optional: true

  include AASM
  aasm column: :status, timestamps: true do
    state :construction, initial: true, display: "En construction"
    state :submitted, display: "En attente d'analyse"
    state :accepted, display: "Accepté"

    event :submit, after_commit: :aasm_after_commit_complete_commune do
      transitions from: :construction, to: :submitted
    end
    event :accept, after_commit: :aasm_after_commit_update do
      transitions from: :submitted, to: :accepted
    end
    event :return_to_construction, after_commit: :aasm_after_commit_return_to_started_commune do
      transitions from: :submitted, to: :construction do
        guard { not_analysed? }
      end
    end
  end

  validates :conservateur, presence: true, if: :accepted?
  validates :commune_id, uniqueness: true # this will be removed with edifices
  validates :visit, inclusion: { in: %w[souhaitable prioritaire] }, allow_nil: true

  delegate :departement, to: :commune

  scope :in_departement, ->(d) { joins(:commune).where(communes: { departement: d }) }
  scope :auto_submittable, -> { where(id: auto_submittable_ids) }
  scope :to_visit, -> { where.not(visit: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }

  def self.auto_submittable_ids
    construction.includes(:recensements, commune: [:objets])
      .to_a
      .select { |dossier| dossier.recensements.all? { _1.created_at < 1.month.ago } }
      .select { |dossier| dossier.recensements.length == dossier.commune.objets.length }
      .map(&:id)
  end

  def full?
    recensements.count == commune.objets.count
  end

  def all_recensements_analysed?
    recensements.where(analysed_at: nil).empty?
  end

  def can_generate_rapport?
    submitted? && all_recensements_analysed?
  end

  def not_analysed?
    recensements.where.not(analysed_at: nil).empty?
  end

  def can_return_to_construction?
    submitted? && not_analysed?
  end

  def analyse_overrides?
    recensements.any?(&:analyse_overrides?)
  end

  def analyse_overrides_count
    recensements.filter(&:analyse_overrides?).count
  end

  def aasm_after_commit_complete_commune(*args, **kwargs)
    aasm_after_commit_update(*args, **kwargs)
    commune.complete! if commune.may_complete?
  end

  def aasm_after_commit_return_to_started_commune(*args, **kwargs)
    aasm_after_commit_update(*args, **kwargs)
    commune.return_to_started!
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[status]
  end
end
