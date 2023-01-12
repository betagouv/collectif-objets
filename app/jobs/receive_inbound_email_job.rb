# frozen_string_literal: true

class ReceiveInboundEmailJob
  include Sidekiq::Job

  def perform(raw)
    message = InboundEmail.from_raw(raw).to_message
    message.save!
    message.enqueue_message_received_emails
    message.inbound_email.enqueue_download_attachments
  end
end
