# frozen_string_literal: true

class DownloadError < StandardError; end

class DownloadInboundEmailAttachmentJob < ApplicationJob
  def perform(attachment_raw, inbound_email_id)
    @email_attachment = EmailAttachment.new(attachment_raw, inbound_email_id)
    return Sidekiq.logger.info("skipping download #{attachment_raw}") if skip_download?

    return Sidekiq.logger.info("skipping already downloaded #{attachment_raw}") if already_downloaded?

    Co::SendInBlueClient.instance.download_inbound_attachment(download_token) { download_callback(_1) }
  end

  private

  attr_reader :email_attachment

  delegate :message, :download_token, :skip_download?, :already_downloaded?, :content_type, :filename,
           to: :email_attachment

  def download_callback(tempfile)
    raise DownloadError, "downloaded file size is #{tempfile.size}" if tempfile.size < 100

    # this is a workaround to prevent attachment deletions cf https://github.com/rails/rails/issues/42941
    blob = ActiveStorage::Blob.create_and_upload!(io: tempfile, content_type:, filename:)
    ActiveStorage::Attachment.create!(blob:, name: "files", record_type: "Message", record_id: message.id)
  end
end

# reload!; DownloadInboundEmailAttachmentJob.perform_inline("<E64ACF4E-304D-4023-B832-4451FECC8AEF@dipasquale.fr>")
