# frozen_string_literal: true

class CampaignEmail < ApplicationRecord
  belongs_to :recipient, foreign_key: :campaign_recipient_id, class_name: "CampaignRecipient", inverse_of: :emails
  has_one :campaign, through: :recipient

  scope :not_final_status, -> { where.not(clicked: true) }

  scope :outdated_synchronization_recent, lambda {
    not_final_status
      .where("created_at > ?", 7.days.ago)
      .where("last_sib_synchronization_at < ?", 22.hours.ago)
  }

  scope :outdated_synchronization_old, lambda {
    not_final_status
      .where("created_at >= ?", 1.month.ago)
      .where("created_at <= ?", 7.days.ago)
      .where("last_sib_synchronization_at < ?", 3.days.ago + 2.hours)
  }

  scope :outdated_synchronization, -> { outdated_synchronization_recent.or(outdated_synchronization_recent) }

  # make sure sent, delivered, opened and clicked are successive steps
  validates :sent, inclusion: { in: [true] }, if: :delivered?
  validates :delivered, inclusion: { in: [true] }, if: :opened?
  validates :opened, inclusion: { in: [true] }, if: :clicked?

  def as_action_mailer_message
    Struct.new(:header, :subject)
      .new(headers.transform_keys(&:downcase), subject)
  end

  def i18n_name
    email_name.gsub(/_email$/, "")
  end

  def redirect_to_sib_path
    return nil if created_at < 30.days.ago # limit in SIB API

    Rails.application.routes.url_helpers.admin_campaign_email_redirect_to_sib_preview_path(campaign, id)
  end
end
