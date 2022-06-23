# frozen_string_literal: true

require "singleton"

module Co
  class SendInBlueClient
    include Singleton

    SIB_LISTS = {
      "production" => {
        "51" => {
          "cold" => 95,
          "enrolled" => 94,
          "opt-out" => 98,
          "started" => 99,
          "missing-photos" => 117
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

    private

    def get_list_id(departement, list_key)
      SIB_LISTS.dig(Rails.env, departement, list_key)
    end

    def contacts_client
      @contacts_client ||= SibApiV3Sdk::ContactsApi.new
    end
  end
end
