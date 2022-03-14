# frozen_string_literal: true

class TriggerSibContactEventJob
  include Sidekiq::Job

  def perform(commune_id, event_name)
    @commune_id = commune_id
    case event_name
    when "enrolled"
      remove_from_lists("cold")
      add_to_lists("enrolled")
    when "started", "completed"
      remove_from_lists("cold", "enrolled")
      add_to_lists("started")
    end
  end

  protected

  def remove_from_lists(*list_names)
    list_names.each { client.remove_contact_from_list(user.email, commune.departement, _1) }
  end

  def add_to_lists(*list_names)
    list_names.each { client.add_contact_to_list(user.email, commune.departement, _1) }
  end

  def client
    @client ||= Co::SendInBlueClient.instance
  end

  def user
    @user ||= commune.users.first
  end

  def commune
    @commune ||= Commune.find(@commune_id)
  end
end
