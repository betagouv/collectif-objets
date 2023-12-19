# frozen_string_literal: true

module Co
  class SendInBlueClient
    class SibServerError < StandardError; end

    include Singleton
    include ActionView::Helpers::NumberHelper

    EMAIL_EVENTS = {
      preserved: %w[delivered requests clicks error].freeze,
      ignored: %w[deferred unsubscribed loadedByProxy].freeze,
      error: %w[bounces hardBounces softBounces spam invalid blocked error].freeze
    }.freeze

    EVENT_STRUCT = Struct.new(:event, :date, :error, :error_reason)
    HOST = "api.sendinblue.com"

    def get_transaction_email_events(message_id)
      get_api_request("/v3/smtp/statistics/events", limit: 20, messageId: message_id).fetch("events", [])
        .map { _1.transform_keys(&:underscore).with_indifferent_access }
        .select { _1[:message_id] == message_id }
        .reject { EMAIL_EVENTS[:ignored].include?(_1[:event]) }
        .map { parse_email_event(_1) }
        .sort_by { _1[:date] }
    end

    def get_transactional_emails(email: nil, message_id: nil)
      filters = { sort: "desc", limit: 20, email:, messageId: message_id }.compact
      get_api_request("/v3/smtp/emails", **filters)["transactionalEmails"]
    end

    def get_transactional_email_uuid(message_id:)
      email = get_transactional_emails(message_id:)&.first
      return nil unless email

      email["uuid"]
    end

    def get_contact(email)
      get_api_request("/v3/contacts/#{email}")
    end

    def list_webhooks = get_api_request("/v3/webhooks")
    def list_inbound_events = get_api_request("/v3/inbound/events")["events"]
    def get_inbound_event(uuid) = get_api_request("/v3/inbound/events/#{uuid}")

    def download_inbound_attachment(download_token)
      f = Tempfile.new "test", binmode: true
      request = Typhoeus::Request.new(
        "https://#{HOST}/v3/inbound/attachments/#{download_token}",
        method: :get,
        headers: { Accept: "application/octet-stream", "api-key": api_key }
      )
      request.on_headers do |response|
        raise "Request failed with status #{response.code}" if response.code != 200
      end
      request.on_body do |chunk|
        f.write(chunk)
      end
      request.on_complete do |_response|
        Rails.logger.info "tempfile downloaded to #{f.path} (size #{number_to_human_size(f.size)})"
        f.rewind
        yield f
        f.close
      end
      request.run
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def parse_email_event(raw)
      date = DateTime.parse(raw[:date])
      if EMAIL_EVENTS[:preserved].include?(raw[:event])
        EVENT_STRUCT.new(raw[:event].underscore, date)
      else
        EVENT_STRUCT.new("error", date, raw[:event].underscore, raw[:reason])
      end
    end

    def get_api_request(path, **params)
      JSON.parse(get_api_request_raw(path, **params))
    end

    def get_api_request_raw(path, **params)
      request = build_request("https://#{HOST}#{path}", method: :get, params:)
      run_request_raw(request)
    end

    def run_request_raw(request, current_retry: 0)
      response = request.run
      raise SibServerError, "error #{response.code}" unless response.code.to_s.starts_with?("2")

      response.body
    rescue SibServerError => e
      raise e if !e.message.match(/error 500/) || current_retry > 4

      Rails.logger.info "Retrying request after SibServerError"
      sleep 1
      run_request_raw(request, current_retry: current_retry + 1)
    end

    def build_request(url, method: :get, **)
      headers = { Accept: "application/json", "api-key": api_key }
      Typhoeus::Request.new(url, method:, headers:, **)
    end

    def api_key
      Rails.application.credentials.sendinblue&.api_key
    end
  end
end
