Rails.application.configure do
  config.good_job.on_thread_error = -> (exception) { Sentry.capture_exception(exception) }

  config.good_job.enable_cron = true
  config.good_job.cron = {
    sanity_checks: {
      cron: "0 5 * * *", # À 5h du matin, tous les jours
      class: "Sanity::ChecksJob"
    },
    sanity_remove_deprecated_edifices: {
      cron: "0 3 * * 0", # À 3h du matin, tous les dimanches
      class: "Sanity::RemoveDeprecatedEdificesJob"
    },
    campaigns: {
      cron: "30 10 * * *", # À 10h30, tous les jours
      class: "Campaigns::CronJob"
    },
    dossiers: {
      cron: "0 8 1 * *", # À 8h tous les 1er du mois
      class: "RelanceDossiersJob"
    },
    departements: {
      cron: "30 8 * * mon", # À 8h30 tous les lundis
      class: "DepartementActiviteJob"
    },
    refresh_all_campaign_stats: {
      cron: "0 8 * * mon-fri", # À 8h tous les jours de semaine
      class: "Campaigns::RefreshAllCampaignStatsJob"
    },
    auto_submit_dossiers: {
      cron: "0 9 * * *", # À 9h du matin, tous les jours
      class: "AutoSubmitDossiersJob"
    },
    purge_unattached_blobs: {
      cron: "0 2 * * *", # À 2h du matin, tous les jours
      class: "PurgeUnattachedBlobsJob"
    },
    remove_old_session_codes: {
      cron: "0 4 * * *", # À 4h du matin, tous les jours
      class: "Sanity::RemoveOldSessionCodesJob"
    },
    synchronize_objets: {
      cron: "0 2 * * 1", # À 2h du matin, tous les lundis
      class: "Synchronizer::Objets::SynchronizeAllJob"
    },
    synchronize_communes: {
      # better to do it after the objets synchronization
      cron: "0 3 * * 1", # À 3h du matin, tous les lundis
      class: "Synchronizer::Communes::SynchronizeAllJob"
    },
    synchronize_edifices: {
      # better to do it after the communes synchronization
      cron: "0 4 * * 1", # À 4h du matin, tous les lundis
      class: "Synchronizer::Edifices::SynchronizeAllJob"
    },
    synchronize_photos: {
      # better to do it after the objets synchronization
      cron: "0 5 * * 1", # À 5h du matin, tous les lundis
      class: "Synchronizer::Photos::SynchronizeAllJob"
    },
  }
end
