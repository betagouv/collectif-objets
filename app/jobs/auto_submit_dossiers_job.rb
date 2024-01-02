# frozen_string_literal: true

class AutoSubmitDossiersJob < ApplicationJob
  def perform
    Dossier.auto_submittable.each { AutoSubmitDossierJob.perform_later(_1.id) }
  end
end
