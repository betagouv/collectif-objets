# frozen_string_literal: true

class ReceiveInboundEmailJob
  include Sidekiq::Job

  def perform(raw)
    @raw = raw
    validate_inbound_email!

    message = inbound_email.to_message
    message.save!
    message.enqueue_message_received_emails
    message.inbound_email.enqueue_download_attachments
  end

  private

  def validate_inbound_email!
    return true if inbound_email.valid?

    raise ArgumentError, "invalid InboundEmail : #{inbound_email.errors.full_messages.to_sentence}"
  end

  def inbound_email
    @inbound_email ||= InboundEmail.from_raw(@raw)
  end
end
