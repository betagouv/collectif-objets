# frozen_string_literal: true

require "singleton"

# rubocop:disable Metrics/ClassLength
module Co
  class SendInBlueClient
    include Singleton

    SIB_LISTS = {
      "production" => {
        "08" => {
          "cold" => 194,
          "enrolled" => 193,
          "opt-out" => 195,
          "started" => 196,
          "missing-photos" => 199
        },
        "26" => {
          "cold" => 232,
          "enrolled" => 234,
          "opt-out" => 235,
          "started" => 233,
          "missing-photos" => 229
        },
        "51" => {
          "cold" => 95,
          "enrolled" => 94,
          "opt-out" => 98,
          "started" => 99,
          "missing-photos" => 117
        },
        "58" => {
          "cold" => 188,
          "enrolled" => 189,
          "opt-out" => 187,
          "started" => 186,
          "missing-photos" => 183
        },
        "65" => {
          "cold" => 112,
          "enrolled" => 111,
          "opt-out" => 113,
          "started" => 114,
          "missing-photos" => 118
        },
        "72" => {
          "enrolled" => 135,
          "opt-out" => 136,
          "started" => 137
        },
        "88" => {
          "cold" => 246,
          "enrolled" => 244,
          "opt-out" => 243,
          "started" => 245,
          "missing-photos" => 249
        }
      },
      "development" => {
        "65" => {
          "cold" => 119,
          "enrolled" => 120,
          "opt-out" => 121,
          "started" => 122,
          "missing-photos" => 123
        }
      }
    }.freeze

    PER_PAGE = 500

    EMAIL_EVENTS = {
      preserved: %w[delivered requests opened clicks error].freeze,
      ignored: %w[deferred unsubscribed loadedByProxy].freeze,
      error: %w[bounces hardBounces softBounces spam invalid blocked error].freeze
    }.freeze

    EVENT_STRUCT = Struct.new(:event, :date, :error, :error_reason)

    def initialize; end

    # BY DEPARTEMENT AND LIST KEY

    def get_list_contacts(departement, list_key)
      list_id = get_list_id(departement, list_key)
      return if list_id.blank?

      get_list_id_contacts(list_id)
    end

    def get_list(departement, list_key)
      list_id = get_list_id(departement, list_key)
      return if list_id.blank?

      contacts_client.get_list(list_id)
    end

    def remove_contact_from_list(email, departement, list_key)
      list_id = get_list_id(departement, list_key)
      return if list_id.blank?

      remove_contact_from_list_id(email, list_id)
    end

    def add_contact_to_list(email, departement, list_key)
      list_id = get_list_id(departement, list_key)
      return if list_id.blank?

      add_contact_to_list_id(email, list_id)
    end

    # BY LIST IDS

    def get_list_id_contacts(list_id, acc = [])
      res = contacts_client.get_contacts_from_list(
        list_id,
        limit: PER_PAGE, # does not seem to be respected
        offset: acc.count
      )
      acc += res.contacts
      res.count == PER_PAGE ? get_list_id_contacts(list_id, acc) : acc
    end

    def remove_contact_from_list_id(email, list_id)
      contact = contacts_client.get_contact_info(email)
      return if contact.list_ids.exclude?(list_id)

      contacts_client.remove_contact_from_list(list_id, { emails: [email] })
    end

    def add_contact_to_list_id(email, list_id)
      contact = contacts_client.get_contact_info(email)
      return if contact.list_ids.include?(list_id)

      contacts_client.add_contact_to_list(list_id, { emails: [email] })
    end

    def get_transaction_email_events(message_id)
      get_api_request("/v3/smtp/statistics/events", limit: 20, messageId: message_id)["events"]
        .map { _1.transform_keys(&:underscore).with_indifferent_access }
        .select { _1[:message_id] == message_id }
        .reject { EMAIL_EVENTS[:ignored].include?(_1[:event]) }
        .map { parse_email_event(_1) }
        .sort_by { _1[:date] }
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

    def get_list_id(departement, list_key)
      SIB_LISTS.dig(Rails.env, departement, list_key)
    end

    def contacts_client
      @contacts_client ||= SibApiV3Sdk::ContactsApi.new
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
# rubocop:enable Metrics/ClassLength
