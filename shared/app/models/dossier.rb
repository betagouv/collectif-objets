# frozen_string_literal: true

class Dossier < ApplicationRecord
  belongs_to :commune
  has_many :recensements, dependent: :nullify
  belongs_to :conservateur, optional: true
  has_one_attached :pdf

  include AASM
  aasm(column: :status, timestamps: true) do
    state :construction, initial: true
    state :submitted
    state :rejected
    state :accepted

    event :submit do
      transitions from: :construction, to: :submitted
      transitions from: :rejected, to: :submitted
    end
    event(:reject) { transitions from: :submitted, to: :rejected }
    event(:accept) { transitions from: :submitted, to: :accepted }
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
end
