# frozen_string_literal: true

module Co
  module Campaigns
    class Ics
      def initialize(campaigns)
        @calendar = Icalendar::Calendar.new
        @campaigns = campaigns
        create_events
        calendar.publish
      end

      delegate :to_ical, to: :calendar

      private

      attr_reader :calendar, :campaigns

      def create_events
        campaigns.each do |campaign|
          Campaign::STEPS.each { add_event(campaign, _1) }
        end
      end

      def add_event(campaign, step)
        date = campaign.send("date_#{step}")
        calendar.event do |e|
          e.dtstart = date
          e.dtend = date + 1.day
          e.summary = "#{step} - #{campaign.departement}"
          e.url = Rails.application.routes.url_helpers.admin_campaign_url(campaign)
        end
      end
    end
  end
end
