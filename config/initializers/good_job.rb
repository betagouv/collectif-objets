Rails.application.configure do
  config.good_job.on_thread_error = -> (exception) { Sentry.capture_exception(exception) }

  config.good_job.enable_cron = true
  config.good_job.cron = {
    sanity_checks: {
      cron: "0 5 * * *",
      class: "SanityChecksJob"
    },
    campaigns: {
      cron: "30 10 * * *",
      class: "Campaigns::CronJob"
    },
    refresh_all_campaign_stats: {
      cron: "0 * * * *",
      class: "Campaigns::RefreshAllCampaignStatsJob"
    },
    auto_submit_dossiers: {
      cron: "0 9 * * *",
      class: "AutoSubmitDossiersJob"
    },
    purge_unattached_blobs: {
      cron: "0 2 * * *",
      class: "PurgeUnattachedBlobsJob"
    }
  }
end
