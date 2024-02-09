# frozen_string_literal: true

class CampaignRecipient < ApplicationRecord
  STATUSES = %w[completed started step_lancement step_relance1 step_relance2 step_relance3 step_fin].freeze
  OPT_OUT_REASONS = %w[postponed other].freeze

  belongs_to :campaign, counter_cache: :recipients_count
  belongs_to :commune
  has_one :departement, through: :commune
  has_many :emails, class_name: "CampaignEmail", dependent: :destroy, inverse_of: :recipient

  validates :commune_id, uniqueness: { scope: :campaign_id }
  validates :current_step, inclusion: { in: [nil] + Campaign::STEPS }
  validates :opt_out_reason, inclusion: { in: OPT_OUT_REASONS }, if: :opt_out?
  validates :opt_out_reason, inclusion: { in: [nil, ""] }, unless: :opt_out?

  # TODO: validate cannot be CRUD for non-draft campaign
  # TODO: validate commune belongs to campaign departement

  validate :validate_inactive
  validate :validate_email

  before_create :set_unsubscribe_token

  def status
    if campaign.draft? || campaign.planned?
      nil
    elsif commune.inactive? && current_step.present?
      "step_#{current_step}"
    elsif !commune.inactive?
      commune.status
    end
  end

  def email_for_step(step)
    emails.where(step:).first
  end

  def email_for_current_step
    email_for_step(current_step)
  end

  def should_skip_mail_for_step(step)
    return false if step == "fin"
    # le mail de fin doit toujours être envoyé

    return true if step == "relance1" && commune.started?
    # pas de premiere relance pour les communes ayant commencé le recensement

    return true if commune.recensements.where(
      "DATE(recensements.updated_at) >= ?",
      (campaign.send("date_#{step}") - 5.days).to_date
    ).any?

    false
  end

  def set_unsubscribe_token
    self.unsubscribe_token ||= SecureRandom.hex(30)
  end

  private

  def validate_inactive
    return if persisted? || (campaign.ongoing? || campaign.finished?)

    errors.add(:commune_id, "Impossible d'intégrer une commune déjà active") unless commune.inactive?
  end

  def validate_email
    return if persisted?

    errors.add(:commune_id, "La commune n'a pas d'email associé") unless commune.users.any?
  end
end
