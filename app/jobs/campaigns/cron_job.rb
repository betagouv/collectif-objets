# frozen_string_literal: true

module Campaigns
  class CronJob
    include Sidekiq::Job

    # this job should be executed daily around 10am
    def perform(date = Time.zone.today)
      Campaign.planned.where("date_lancement <= ?", date).find_each(&:start!)

      Campaign.ongoing.each { Campaigns::RunCampaignJob.perform_inline(_1.id) }

      # strict comparison here so that it closes day after end
      Campaign.ongoing.where("date_fin < ?", date).find_each(&:finish!)

      # Envoi de la réponse automatique pour les communes n'ayant recensé que des objets verts
      Campaign.finished.each do |campaign|
        campaign.communes.each do |commune|
          next unless commune.shall_receive_email_objets_verts(date)

          commune.dossier.update(replied_automatically_at: date)
          UserMailer.with(user: commune.users.first, commune:).commune_avec_objets_verts_email.deliver_now
        end
      end
    end
  end
end
