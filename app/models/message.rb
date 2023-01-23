# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :commune
  belongs_to :inbound_email, optional: true
  belongs_to :author, polymorphic: true

  validates :origin, inclusion: { in: %w[web inbound_email] }

  has_many_attached :files do |attachable|
    attachable.variant :small, resize_to_limit: [300, 400], saver: { strip: true }
  end

  after_create_commit :enqueue_mattermost_notification

  def inbound_email? = origin == "inbound_email"

  def web? = origin == "web"

  def enqueue_message_received_emails
    case author
    when User
      enqueue_message_received_emails_for_conservateurs
    when Conservateur, AdminUser
      enqueue_message_received_emails_for_users
    end
  end

  delegate :attachments, :skipped_attachments, to: :inbound_email, allow_nil: true

  def enqueue_mattermost_notification
    delay = inbound_email? && inbound_email.attachments.any? ? 3.minutes : 0
    SendMattermostNotificationJob.perform_in(
      delay, # to give time for attachments to be downloaded in case there are any
      "message_created", "message_id" => id
    )
  end

  def files_and_skipped_attachments_count
    files.count + (skipped_attachments || []).length
  end

  private

  def enqueue_message_received_emails_for_conservateurs
    commune.departement.conservateurs.each do |conservateur|
      next unless conservateur.messages_mail_notifications?

      ConservateurMailer.with(message: self, conservateur:).message_received_email.deliver_later
    end
  end

  def enqueue_message_received_emails_for_users
    commune.users.each do |user|
      next unless user.messages_mail_notifications?

      UserMailer.with(message: self, user:).message_received_email.deliver_later
    end
  end
end
