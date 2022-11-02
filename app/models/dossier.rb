# frozen_string_literal: true

class Dossier < ApplicationRecord
  belongs_to :commune
  has_many :recensements, dependent: :nullify
  has_many :objets, through: :recensements
  belongs_to :conservateur, optional: true
  belongs_to :edifice, optional: true

  include AASM
  aasm column: :status, timestamps: true do
    state :construction, initial: true, display: "En construction"
    state :submitted, display: "En attente d'analyse"
    state :rejected, display: "Renvoyé à la commune"
    state :accepted, display: "Accepté"

    event :submit, after_commit: :aasm_after_commit_complete_commune do
      transitions from: :construction, to: :submitted
      transitions from: :rejected, to: :submitted
    end
    event :reject, after_commit: :aasm_after_commit_update do
      transitions from: :submitted, to: :rejected
    end
    event :accept, after_commit: :aasm_after_commit_update do
      transitions from: :submitted, to: :accepted
      transitions from: :construction, to: :accepted do
        guard { author_conservateur? }
      end
    end
    event :return_to_construction, after_commit: :aasm_after_commit_return_to_started_commune do
      transitions from: :submitted, to: :construction do
        guard { not_analysed? }
      end
    end
  end

  validates :conservateur, presence: true, if: :accepted?
  validates :commune_id, uniqueness: true, if: :scope_commune?
  validates :edifice_id, uniqueness: true, if: :scope_edifice?
  validates :author_role, inclusion: { in: %w[user conservateur] }

  delegate :departement, to: :commune

  def self.current(dossier_arel)
    dossier_arel.to_a.max_by(&:created_at) # avoids n+1 query
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

  def author_user? = author_role == "user"
  def author_conservateur? = author_role == "conservateur"

  def scope
    edifice_id.present? ? :edifice : :commune
  end

  def scope_commune? = scope == :commune
  def scope_edifice? = scope == :edifice

  # def scope_edifice? = scope == :edifice
end
