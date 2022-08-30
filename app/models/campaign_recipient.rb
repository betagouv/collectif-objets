# frozen_string_literal: true

class CampaignRecipient < ApplicationRecord
  STATUSES = %w[completed started enrolled step_lancement step_rappel1 step_rappel2 step_rappel3 step_fin].freeze
  OPT_OUT_REASONS = %w[postponed other].freeze

  belongs_to :campaign
  belongs_to :commune
  has_many :emails, class_name: "CampaignEmail", dependent: :destroy, inverse_of: :recipient

  validates :commune_id, uniqueness: { scope: :campaign_id }
  validates :current_step, inclusion: { in: [nil] + Campaign::STEPS }
  validates :opt_out_reason, inclusion: { in: OPT_OUT_REASONS }, if: :opt_out?
  validates :opt_out_reason, inclusion: { in: [nil, ""] }, unless: :opt_out?

  # TODO: validate cannot be CRUD for non-draft campaign
  # TODO: validate commune belongs to campaign departement

  validate :validate_inactive

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

  private

  def validate_inactive
    return if persisted? || (campaign.ongoing? || campaign.finished?)

    errors.add(:commune_id, "Impossible d'intégrer une commune déjà active") unless commune.inactive?
  end
end
