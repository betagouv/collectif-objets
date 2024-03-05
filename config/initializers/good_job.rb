Rails.application.configure do
  config.good_job.on_thread_error = -> (exception) { Sentry.capture_exception(exception) }

  config.good_job.enable_cron = true
  config.good_job.cron = {
    sanity_checks: {
      cron: "0 5 * * *",
      class: "Sanity::ChecksJob"
    },
    sanity_remove_deprecated_edifices: {
      cron: "0 3 * * 0", # every sunday at 3am
      class: "Sanity::RemoveDeprecatedEdificesJob"
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
    },
    remove_old_session_codes: {
      cron: "0 4 * * *",
      class: "Sanity::RemoveOldSessionCodesJob"
    },
    synchronize_objets: {
      cron: "0 2 * * 1", # every monday at 2am,
      class: "Synchronizer::Objets::SynchronizeAllJob"
    },
    synchronize_communes: {
      # better to do it after the objets synchronization
      cron: "0 3 * * 1", # every monday at 3am,
      class: "Synchronizer::Communes::SynchronizeAllJob"
    },
    synchronize_edifices: {
      # better to do it after the communes synchronization
      cron: "0 4 * * 1", # every monday at 4am,
      class: "Synchronizer::Edifices::SynchronizeAllJob"
    },
    synchronize_photos: {
      # better to do it after the objets synchronization
      cron: "0 5 * * 1", # every monday at 5am,
      class: "Synchronizer::Photos::SynchronizeAllJob"
    },
  }
end
