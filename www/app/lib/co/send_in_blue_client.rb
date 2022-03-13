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
          "completed" => 99,
          "missing-photos" => 117
        },
        "65" => {
          "cold" => 112,
          "enrolled" => 111,
          "opt-out" => 113,
          "completed" => 114,
          "missing-photos" => 118
        }
      },
      "development" => {
        "51" => {
          "cold" => 119,
          "enrolled" => 120,
          "opt-out" => 121,
          "completed" => 122,
          "missing-photos" => 123
        }
      }
    }.freeze

    PER_PAGE = 500

    def initialize; end

    def get_list_contacts(departement, name, acc = [])
      res = contacts_client.get_contacts_from_list(
        get_list_id!(departement, name),
        limit: PER_PAGE, # does not seem to be respected
        offset: acc.count
      )
      sleep(1)
      acc += res.contacts
      res.count == PER_PAGE ? get_list_contacts(departement, name, acc) : acc
    end

    def get_list(departement, name)
      contacts_client.get_list(get_list_id!(departement, name))
    end

    def contacts_client
      @contacts_client ||= SibApiV3Sdk::ContactsApi.new
    end

    private

    def get_list_id!(departement, name)
      SIB_LISTS.dig(Rails.env, departement, name) || raise("missing list #{Rails.env} #{departement} - #{name}")
    end
  end
end
