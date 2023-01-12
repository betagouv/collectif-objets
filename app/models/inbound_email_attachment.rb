# frozen_string_literal: true

class InboundEmailAttachment
  attr_reader :raw

  def initialize(raw, inbound_email_id)
    @raw = raw
    @inbound_email_id = inbound_email_id
  end

  def download_token = raw["DownloadToken"]
  def content_type = raw["ContentType"]
  def filename = raw["Name"]
  def size = raw["ContentLength"]
  def extension = File.extname(filename)[1..].downcase

  def inbound_email
    @inbound_email ||= InboundEmail.find(@inbound_email_id)
  end

  delegate :message, to: :inbound_email

  def should_download?
    size > 1024 * 100 &&
      size < 1024 * 10_000 &&
      %w[jpg zip pdf].include?(extension)
  end

  def skip_download?
    !should_download?
  end

  def already_downloaded?
    message.files_blobs.any? { _1.filename == filename }
  end
end
