# frozen_string_literal: true

class AutoSubmitDossiersJob < ApplicationJob
  def perform
    Dossier.auto_submittable.pluck(:id).each { AutoSubmitDossierJob.perform_later(_1) }
  end
end
