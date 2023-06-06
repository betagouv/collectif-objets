# frozen_string_literal: true

class InboundEmail < ApplicationRecord
  has_one :message, dependent: :destroy

  SUPPORT_EMAIL_REGEX = /
    mairie-
    (?<code_insee>[a-z0-9]{5})-
    (?<conservateur>conservateur-)?
    (?<token>[a-z0-9]{20})
    @
    [a-z-]+.collectifobjets.org
  /x

  validates :to_email, presence: { message: "Aucun email de destinataire reconnu" }, format: {
    with: SUPPORT_EMAIL_REGEX,
    message: "Aucun email reconnu comme un email de support (ni To, ni Cc)"
  }

  def self.from_raw(raw)
    to_emails = (raw.fetch("To", []) + raw.fetch("Cc", [])).pluck("Address")
    to_email = to_emails.find { _1.match(SUPPORT_EMAIL_REGEX) } || to_emails.first
    new \
      id: raw["MessageId"],
      body_html: raw["RawHtmlBody"],
      body_text: raw["RawTextBody"],
      body_md: raw["ExtractedMarkdownMessage"],
      signature_md: raw["ExtractedMarkdownSignature"],
      from_email: raw.dig("From", "Address"),
      to_email:,
      sent_at: raw["SentAtDate"],
      raw: raw.except("RawHtmlBody", "RawTextBody", "ExtractedMarkdownMessage", "ExtractedMarkdownSignature")
  end

  # cf https://developers.sendinblue.com/docs/inbound-parse-webhooks#sample-payload

  def author_type = regex_match[:conservateur] ? :conservateur : :user
  def commune_token = regex_match[:token]
  def commune_code_insee = regex_match[:code_insee]

  def commune
    return nil unless regex_match

    Commune.find_by(inbound_email_token: commune_token, code_insee: commune_code_insee)
  end

  def author
    return nil if !regex_match || commune.nil?

    case author_type
    when :conservateur
      author_conservateur
    when :user
      author_user
    end
  end

  def to_message
    build_message origin: :inbound_email, commune:, author:
  end

  def attachments
    raw.fetch("Attachments", []).each_with_index.map { |raw, index| EmailAttachment.new(raw, id, index:) }
  end

  def skipped_attachments = attachments.select(&:skip_download?)

  def enqueue_download_attachments
    attachments
      .select(&:should_download?)
      .each { DownloadInboundEmailAttachmentJob.perform_async(_1.raw, id) }
  end

  private

  def regex_match
    @regex_match ||= to_email&.match(SUPPORT_EMAIL_REGEX)
  end

  def author_conservateur
    scoped = Conservateur.joins(:departements).where(departements: { code: commune.departement_code })
    scoped.where(email: from_email).first || scoped.first
  end

  def author_user
    scoped = commune.users
    scoped.find_by("email ILIKE ?", from_email) || scoped.first
  end
end
