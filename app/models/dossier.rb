# frozen_string_literal: true

class Dossier < ApplicationRecord
  belongs_to :commune
  belongs_to :campaign, optional: true
  has_many :recensements, dependent: :nullify
  has_many :objets, through: :recensements
  belongs_to :conservateur, optional: true

  include AASM
  aasm column: :status, timestamps: true, whiny_persistence: true do
    state :construction, initial: true, display: I18n.t("dossier.status_badge.construction")
    state :submitted, display: I18n.t("dossier.status_badge.submitted")
    state :accepted, display: I18n.t("dossier.status_badge.accepted")
    state :archived, display: I18n.t("dossier.status_badge.archived")

    event :submit, after: :aasm_after_submit do
      transitions from: :construction, to: :submitted
    end
    event :accept, after: :aasm_after_accept do
      transitions from: :submitted, to: :accepted
    end
    event :archive do
      transitions from: [:construction, :submitted, :accepted], to: :archived
    end
    event :return_to_construction, after: :aasm_after_return_to_construction do
      transitions from: :submitted, to: :construction do
        guard { not_analysed? }
      end
    end
    event :reopen do
      transitions from: :accepted, to: :submitted
    end
  end

  validates :conservateur, presence: true, if: :accepted?
  validates :visit, inclusion: { in: %w[souhaitable prioritaire] }, allow_nil: true
  validates :commune_id, uniqueness: true, unless: :archived?

  delegate :departement, to: :commune

  scope :in_departement, ->(d) { joins(:commune).where(communes: { departement: d }) }
  scope :auto_submittable, -> { where(id: auto_submittable_ids) }
  scope :to_visit, -> { where.not(visit: nil) }
  scope :current, -> { where.not(status: "archived") }
  scope :submitted_in, ->(date_range) { where(submitted_at: date_range) if date_range }

  before_create :set_campaign

  def self.auto_submittable_ids
    construction.includes(:recensements, commune: [:objets])
      .to_a
      .select { |dossier| dossier.recensements.all? { _1.created_at < 1.month.ago } }
      .select { |dossier| dossier.recensements.length == dossier.commune.objets.length }
      .map(&:id)
  end

  def construction_at = created_at

  def title
    date = I18n.l(send("#{status}_at").to_date, format: :long)
    I18n.t("dossier.title_#{status}", date:)
  end

  def full?
    recensements.count == commune.objets.count
  end

  def can_generate_rapport?
    submitted? && recensements.prioritaires.not_analysed.empty?
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

  def a_des_objets_prioritaires?
    recensements.prioritaires.count.positive?
  end

  def replied_automatically?
    replied_automatically_at.present?
  end

  def aasm_after_submit(updates = {}, **_kwargs)
    update(notes_commune: updates[:notes_commune]) if updates.key?(:notes_commune)
    update(recenseur: updates[:recenseur]) if updates.key?(:recenseur)
    commune.complete! unless commune.completed?
  end

  def aasm_after_return_to_construction
    commune.return_to_started! unless commune.started?
  end

  def aasm_after_accept
    commune.recensements.where.not(status: "completed").find_each(&:destroy!)
  end

  def self.ransackable_attributes(_ = nil) = %w[status submitted_at]

  private

  def set_campaign
    self.campaign_id ||= commune.campaigns.ongoing.ids.first
  end
end
