# frozen_string_literal: true

module Api
  module V1
    class InboundEmailsController < BaseController
      before_action :validate_ip, unless: Rails.application.config.x.waf_protection_active

      PERMITTED_PARAMS_ROOT = %w[
        MessageId InReplyTo ReplyTo SentAtDate Subject RawHtmlBody RawTextBody ExtractedMarkdownMessage
        ExtractedMarkdownSignature SpamScore
      ].freeze
      PERMITTED_PARAMS_NESTED = [
        {
          "Uuid" => [],
          "From" => %w[Name Address],
          "To" => %w[Name Address],
          "Cc" => %w[Name Address],
          "Attachments" => %w[Name ContentType ContentLength ContentID DownloadToken],
          "Headers" => %w[
            Return-Path Delivered-To Received ARC-Seal ARC-Message-Signature ARC-Authentication-Results DKIM-Signature
            MIME-Version References In-Reply-To From Date Message-ID Subject To Content-Type Received-SPF
          ]
        }
      ].freeze
      PERMITTED_PARAMS = { "items" => PERMITTED_PARAMS_ROOT + PERMITTED_PARAMS_NESTED }.freeze

      def create
        items.each { ReceiveInboundEmailJob.perform_later(_1) }
        render json: { success: true }
      rescue ArgumentError => e
        Sentry.configure_scope { _1.set_context(items:) }
        raise e
      end

      private

      def validate_ip
        # cf https://developers.sendinblue.com/docs/how-to-use-webhooks#securing-your-webhooks
        return if Rails.application.config.x.inbound_allowed_ips.any? { |mask| request.ip.start_with?(mask) }

        render status: :forbidden, json: { error: "IP not authorized" }
      end

      def items
        @items ||= params.permit(PERMITTED_PARAMS)["items"].map(&:to_hash)
      end
    end
  end
end
