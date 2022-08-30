# frozen_string_literal: true

class CampaignEmail < ApplicationRecord
  belongs_to :recipient, foreign_key: :campaign_recipient_id, class_name: "CampaignRecipient", inverse_of: :emails

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
    Struct.new(:header, :subject, :body)
      .new(headers.transform_keys(&:downcase), subject, raw_html)
  end
end
