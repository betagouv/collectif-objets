# frozen_string_literal: true

class SanityChecksJob
  include Sidekiq::Job

  EMAIL = "adrien.di_pasquale@beta.gouv.fr"

  def perform
    check_commune_started_dossier_construction
    check_commune_completed_dossier_submitted
  end

  protected

  def check_commune_started_dossier_construction
    Commune.started.joins(:dossier).where.not(dossiers: { status: :construction }).each do |commune|
      text = "La commune #{commune} est en `started` mais son dossier est " \
             "`#{commune.dossier.status}` au lieu de `construction`"
      logger.info text
      AdminMailer.with(email: EMAIL, commune:, text:).sanity_check_alert.deliver_later
    end
  end

  def check_commune_completed_dossier_submitted
    Commune.completed.joins(:dossier)
      .where.not(dossiers: { status: %i[submitted accepted] })
      .each do |commune|
      text = "La commune #{commune} est en `completed` mais son dossier est " \
             "`#{commune.dossier.status}` au lieu de `submitted` ou `accepted`"
      logger.info text
      AdminMailer.with(email: EMAIL, commune:, text:).sanity_check_alert.deliver_later
    end
  end
end
