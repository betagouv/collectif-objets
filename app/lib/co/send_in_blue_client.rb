# frozen_string_literal: true

require "singleton"

module Co
  class SendInBlueClient
    include Singleton

    EMAIL_EVENTS = {
      preserved: %w[delivered requests opened clicks error].freeze,
      ignored: %w[deferred unsubscribed loadedByProxy].freeze,
      error: %w[bounces hardBounces softBounces spam invalid blocked error].freeze
    }.freeze

    EVENT_STRUCT = Struct.new(:event, :date, :error, :error_reason)

    def get_transaction_email_events(message_id)
      get_api_request("/v3/smtp/statistics/events", limit: 20, messageId: message_id)["events"]
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
      url = URI::HTTPS.build(host: "api.sendinblue.com", query: params.to_query, path:)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"
      request["api-key"] = api_key
      http.request(request).read_body
    end

    def api_key
      Rails.application.credentials.sendinblue&.api_key
    end
  end
end
