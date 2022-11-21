# frozen_string_literal: true

class Campaign < ApplicationRecord
  STATUSES = %i[draft planned ongoing finished].freeze
  STEPS = %w[lancement relance1 relance2 relance3 fin].freeze
  DATE_FIELDS = STEPS.map { "date_#{_1}" }.freeze

  belongs_to :departement, foreign_key: :departement_code, inverse_of: :campaigns
  has_many :recipients, class_name: "CampaignRecipient", dependent: :destroy
  has_many :communes, through: :recipients
  has_many :objets, through: :communes
  has_many :emails, class_name: "CampaignEmail", through: :recipients

  accepts_nested_attributes_for :recipients, allow_destroy: true

  include AASM
  aasm(column: :status, timestamps: true) do
    state :draft, initial: true, display: "En configuration"
    state :planned, display: "Planifié"
    state :ongoing, display: "En cours"
    state :finished, display: "Terminée"

    event(:plan) { transitions from: :draft, to: :planned, guard: :only_inactive_communes? }
    event(:return_to_draft) { transitions from: :planned, to: :draft }
    event(:start) { transitions from: :planned, to: :ongoing }
    event(:finish) { transitions from: :ongoing, to: :finished }
  end

  validates :date_lancement, :date_relance1, :date_relance2, :date_relance3, :date_fin, presence: true
  validates :sender_name, :signature, :nom_drac, presence: true, unless: :draft?

  validate :validate_successive_dates, if: :dates_are_present?
  validate :validate_starts_in_the_future, if: -> { dates_are_present? && (draft? || planned?) }
  validate :validate_weekdays, if: :dates_are_present?
  validate :validate_no_overlapping_campaigns, if: -> { dates_are_present? && planned? }

  include Campaigns::ForceStepUpConcern

  def human_id
    [departement.nom, date_lancement.strftime("%m/%y")].join("-").parameterize
  end
  alias to_s human_id

  def step_for_date(date)
    return nil if date < date_lancement

    STEPS.reverse.find { date >= send("date_#{_1}") }
  end

  def current_step
    step_for_date(Time.zone.today)
  end

  def previous_step
    Campaign.previous_step_for(current_step)
  end

  def next_step
    Campaign.next_step_for(current_step)
  end

  def self.previous_step_for(step)
    return nil if step == "lancement"

    STEPS[STEPS.find_index(step) - 1]
  end

  def self.next_step_for(step)
    return nil if step == "fin"

    STEPS[STEPS.find_index(step) + 1]
  end

  def validate_successive_dates
    DATE_FIELDS.each_cons(2) do |d1, d2|
      next unless send(d2) <= send(d1)

      t1, t2 = [d1, d2].map { I18n.t("activerecord.attributes.campaign.#{_1}").downcase }
      return errors.add(d2, "La #{t2} doit être postérieure à la #{t1}")
    end
  end

  def validate_starts_in_the_future
    return if date_lancement > Time.zone.today

    errors.add(:date_lancement, "La date de lancement ne peut pas être dans le passé")
  end

  def validate_weekdays
    DATE_FIELDS.each do |d|
      next unless send(d).saturday? || send(d).sunday?

      t = I18n.t("activerecord.attributes.campaign.#{d}").downcase
      errors.add(d, "La #{t} ne peut pas être un samedi ou un dimanche")
    end
  end

  def validate_no_overlapping_campaigns
    overlapping_campaign = Campaign
      .where(status: %i[ongoing planned])
      .where(departement:)
      .first { date_range.overlaps?(_1.date_range) }

    return if overlapping_campaign.nil?

    errors.add(:date_lancement, "La plage de dates ne peut pas recouper la campagne #{overlapping_campaign}")
  end

  def date_range
    @date_range ||= Range.new date_lancement, date_fin
  end

  def only_inactive_communes?
    return true if communes.where.not(status: "inactive").empty?
  end

  def stats
    super&.with_indifferent_access
  end

  def past_steps
    index = DATE_FIELDS.rindex { send(_1) <= Time.zone.today }
    return [] if index.blank?

    STEPS[0..index]
  end

  def dates_are_present?
    DATE_FIELDS.map { send(_1) }.all?(&:present?)
  end
end
