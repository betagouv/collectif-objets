# frozen_string_literal: true

module Conservateurs
  class MailIframeComponent < ApplicationComponent
    attr_reader :mail, :display_headers, :fit, :redirect_path

    IFRAME_CSS = <<-HTML
      <style>
        body {
          background: white;
        }
        a{
          pointer-events: none;
        }
      </style>
    HTML

    def self.from_campaign_email(campaign_email)
      new(mail: campaign_email.as_action_mailer_message, redirect_path: campaign_email.redirect_to_sib_path)
    end

    def initialize(mail:, display_headers: true, fit: false, redirect_path: nil)
      @mail = mail
      @display_headers = display_headers
      @fit = fit
      @redirect_path = redirect_path
      super
    end

    def html_body
      mail_body || mail_html_part_body || redirect_body || "<i>contenu du mail indisponible</i>"
    end

    def text_body
      mail_text || "version textuelle non définie"
    end

    def id
      @id ||= @mail.object_id || "mail_#{SecureRandom.hex(4)}"
    end

    private

    def mail_body
      mail.respond_to?("body") && mail.body.to_s.presence
    end

    def mail_html_part_body
      mail.respond_to?("html_part") && mail.html_part.body.to_s.presence
    end

    def mail_text
      mail.respond_to?("text_part") && mail.text_part.decoded
    end

    def redirect_body
      return if redirect_path.blank?

      <<-HTML
        <a href='#{redirect_path}' target="_top">
          Voir le contenu du mail sur Send In Blue
        </a>
      HTML
    end
  end
end
