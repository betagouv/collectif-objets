# frozen_string_literal: true

class AutoSubmitDossiersJob
  include Sidekiq::Job

  def perform
    Dossier.auto_submittable.each { AutoSubmitDossierJob.perform_async(_1.id) }
  end
end
