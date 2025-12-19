# frozen_string_literal: true

class DossierCompletion
  attr_reader :dossier

  delegate :commune, :notes_commune, :recenseur, to: :dossier

  def initialize(dossier:)
    @dossier = dossier
  end

  def create!(user:, notes_commune:, recenseur:)
    return false unless dossier.submit!(notes_commune:, recenseur:)

    SendMattermostNotificationJob.perform_later("commune_completed", { "commune_id" => commune.id })
    commune_user = commune.users.first
    UserMailer.with(user: commune_user, commune:).commune_completed_email.deliver_later if commune_user

    true
  end
end
