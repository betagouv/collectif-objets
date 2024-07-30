# frozen_string_literal: true

class RemovePersonalInformationJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  def perform(dossier_id)
    @dossier = Dossier.find(dossier_id)
    # On utilise update_columns pour éviter les validations qui pourraient faire échouer la tâche
    @dossier.update_columns(recenseur: nil, updated_at: Time.zone.now)
  end
end
