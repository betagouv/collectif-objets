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
    Campaign::STEPS.to_h { [_1, stats_for_step(_1)] }
  end

  def stats_for_step(step)
    StatsForEmailsGroup.new(all_emails.select { _1["step"].to_s == step.to_s }).stats
  end
end

class StatsForEmailsGroup
  def initialize(emails)
    @emails = emails
  end

  def stats
    @stats ||= compute_stats
    raise "total is incorrect !" unless valid?

    @stats
  end

  def valid?
    @stats[:count] == %i[pending error sent delivered opened clicked]
      .map { @stats[_1][:count_exclusive] }.sum
  end

  private

  attr_reader :emails

  def compute_stats
    base_stats.deep_merge(
      pending: { count_exclusive: base_stats[:count] - c(:error) - c(:sent) },
      error: { count_exclusive: c(:error) },
      sent: { count_exclusive: c(:sent) - c(:delivered) },
      delivered: { count_exclusive: c(:delivered) - c(:opened) },
      opened: { count_exclusive: c(:opened) - c(:clicked) },
      clicked: { count_exclusive: c(:clicked) }
    )
  end
  # rubocop:enable Metrics/AbcSize

  def base_stats
    @base_stats ||= { count: emails.count }.merge(
      CampaignStats::ATTRIBUTES.to_h { [_1, base_stats_for_attribute(_1)] }
    )
  end

  def base_stats_for_attribute(attribute)
    count = emails.count { _1[attribute.to_s].present? && (attribute == :error || !_1["error"]) }
    ratio = (count.to_f / emails.count).round(4)
    { count:, ratio: }
  end

  def c(key)
    base_stats[key][:count]
  end
end
