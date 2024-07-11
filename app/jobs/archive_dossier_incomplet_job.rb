# frozen_string_literal: true

class ArchiveDossierIncompletJob < ApplicationJob
  def perform(dossier_id)
    Dossier.find(dossier_id).archive!
  end
end
