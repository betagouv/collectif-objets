# frozen_string_literal: true

class Dossier < ApplicationRecord
  belongs_to :commune
  has_many :recensements, dependent: :nullify
  belongs_to :conservateur, optional: true
  has_one_attached :pdf

  include AASM
  aasm(column: :status, timestamps: true) do
    state :construction, initial: true, display: "En construction"
    state :submitted, display: "En attente d'analyse"
    state :rejected, display: "Renvoyé à la commune"
    state :accepted, display: "Accepté"

    event :submit, after_commit: :aasm_after_commit_complete_commune do
      transitions from: :construction, to: :submitted
      transitions from: :rejected, to: :submitted
    end
    event(:reject, after_commit: :aasm_after_commit_update) do
      transitions from: :submitted, to: :rejected
    end
    event(:accept, after_commit: :aasm_after_commit_update) do
      transitions from: :submitted, to: :accepted
    end
  end

  validates :conservateur, presence: true, if: :accepted?
  validates :commune_id, uniqueness: true # this will be removed with edifices

  delegate :departement, to: :commune

  def all_recensements_analysed?
    recensements.where(analysed_at: nil).empty?
  end

  def can_generate_rapport?
    submitted? && all_recensements_analysed?
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
end
