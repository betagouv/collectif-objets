# frozen_string_literal: true

module Campaigns
  class CronJob
    include Sidekiq::Job

    # this job should be executed daily around 10am
    def perform(date = Time.zone.today)
      Campaign.planned.where("date_lancement <= ?", date).each(&:start!)

      Campaign.ongoing.each { Campaigns::RunCampaignJob.perform_inline(_1.id) }

      Campaign.ongoing.where("date_fin < ?", date).each(&:finish!)
      # strict comparison here so that it closes day after end
    end
  end
end
