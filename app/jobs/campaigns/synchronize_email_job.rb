# frozen_string_literal: true

module Campaigns
  class SynchronizeEmailJob
    include Sidekiq::Job
    include Sidekiq::Throttled::Worker

    sidekiq_throttle(threshold: { limit: 250, period: 1.hour })
    sidekiq_options retry: 4

    delegate :sib_message_id, to: :campaign_email
    attr_reader :campaign_email

    def perform(campaign_email_id)
      @campaign_email = CampaignEmail.find(campaign_email_id)
      return if sib_message_id.blank?

      update_email!
    end

    private

    def sib_events
      @sib_events ||= Co::SendInBlueClient.instance.get_transaction_email_events(sib_message_id)
    end

    def sib_event_keys
      @sib_event_keys ||= sib_events.pluck(:event)
    end

    def event_occured?(event)
      sib_event_keys.include?(event.to_s)
    end

    def error_event
      @error_event ||= sib_events.select { _1.event == "error" }.first
    end

    def update_email!
      @campaign_email.update!(
        sent: event_occured?("requests"),
        delivered: event_occured?("delivered"),
        opened: event_occured?("opened") || event_occured?("clicks"),
        clicked: event_occured?("clicks"),
        error: error_event&.error,
        error_reason: error_event&.error_reason,
        last_sib_synchronization_at: Time.zone.now,
        sib_events:
      )
    end
  end
end
