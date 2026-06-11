# frozen_string_literal: true

class CampaignStats
  ATTRIBUTES = %i[sent delivered opened clicked error].freeze

  def initialize(campaign)
    @campaign = campaign
  end

  def stats
    { objets: objets_stats, statuses: statuses_stats, mails: mails_stats }
  end

  private

  attr_reader :campaign

  def objets_stats
    total = campaign.objets.count
    recensed = campaign.recensements.count
    recensed_with_photo = campaign.recensements.with_photos.count
    {
      total:,
      recensed:,
      not_recensed: total - recensed,
      recensed_with_photo:,
      recensements_with_photos_ratio: recensed.positive? && (recensed_with_photo.to_f / recensed).round(4)
    }
  end

  def statuses_stats
    { total: campaign.recipients_count }.merge campaign.dossiers.group(:status).count
  end

  def mails_stats
    return {} if campaign.imported?

    { all: StatsForEmailsGroup.new(all_emails).stats }.merge(steps_stats)
  end

  def all_emails
    @all_emails ||= @campaign.emails.select(:step, *ATTRIBUTES).as_json # actually hashes
  end

  def steps_stats
    Campaign::STEPS.index_with { stats_for_step(it) }
  end

  def stats_for_step(step)
    StatsForEmailsGroup.new(all_emails.select { it["step"].to_s == step.to_s }).stats
  end
end
