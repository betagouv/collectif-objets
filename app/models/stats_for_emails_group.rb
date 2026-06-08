# frozen_string_literal: true

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
      .map { @stats[it][:count_exclusive] }.sum
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

  def base_stats
    @base_stats ||= { count: emails.count }.merge(
      CampaignStats::ATTRIBUTES.index_with { base_stats_for_attribute(it) }
    )
  end

  def base_stats_for_attribute(attribute)
    count = emails.count { it[attribute.to_s].present? && (attribute == :error || !it["error"]) }
    ratio = (count.to_f / emails.count).round(4)
    { count:, ratio: }
  end

  def c(key)
    base_stats[key][:count]
  end
end
