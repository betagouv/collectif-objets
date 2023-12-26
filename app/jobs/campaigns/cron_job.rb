# frozen_string_literal: true

module Campaigns
  class CronJob
    include Sidekiq::Job

    # this job should be executed daily around 10am
    def perform(date = Time.zone.today)
      Campaign.planned.where("date_lancement <= ?", date).find_each(&:start!)

      Campaign.ongoing.each { Campaigns::RunCampaignJob.perform_inline(_1.id) }

      # strict comparison here so that it closes day after end
      Campaign.ongoing.where("date_fin < ?", date).find_each do |campaign|
        campaign.finish!

        campaign.communes.each do |commune|
          user = commune.users.first
          next unless user.present? && commune.statut_global == Commune::ORDRE_A_EXAMINER \
            && !commune.dossier.a_des_objets_prioritaires?

          commune.dossier.update(replied_automatically_at: Time.zone.now)
          UserMailer.with(user:, commune:).commune_avec_objets_verts_email.deliver_now
        end
      end
    end
  end
end
