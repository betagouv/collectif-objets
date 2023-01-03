# frozen_string_literal: true

class AutoSubmitDossiersJob
  include Sidekiq::Job

  def perform
    dossiers.each { _1.submit!(notes_commune: "Dossier soumis automatiquement après plus de 30 jours d'inactivité") }
    SendMattermostNotificationJob.perform_async("dossiers_auto_submitted", { "dossiers_id" => dossiers.map(&:id) })
  end

  private

  def dossiers
    @dossiers ||= Dossier.auto_submittable
  end
end
