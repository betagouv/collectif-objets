# frozen_string_literal: true

class MoveSibContactsBetweenListsJob
  include Sidekiq::Job

  def perform(from_id, to_id)
    Co::SendInBlueClient.instance.get_list_id_contacts(from_id).each do |contact|
      Co::SendInBlueClient.instance.remove_contact_from_list_id(contact[:email], from_id)
      Co::SendInBlueClient.instance.add_contact_to_list_id(contact[:email], to_id)
    end
  end
end
