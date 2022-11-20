# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

ActiveAdmin.register_page "campaign_calendar" do
  menu label: "🚀 Campagnes", priority: 9
  content do
    render partial: "campaign_calendars"
  end

  controller do
    include ApplicationHelper
    helper_method :month_calendars

    def events
      @events ||= compute_events
    end

    def compute_events
      event_struct = Struct.new(:step, :campaign)
      all_events = {}
      Campaign.where.not(status: "draft").each do |campaign|
        Campaign::STEPS.each do |step|
          date = campaign.send("date_#{step}")
          all_events[date] ||= []
          all_events[date] << event_struct.new(step, campaign)
        end
      end
      all_events
    end

    def month_calendars
      today = Time.zone.today
      (-1..3).map { Calendar.new(today.beginning_of_month + _1.months, events) }
    end
  end
end

class Calendar
  START_DAY = :monday
  WEEK_STRUCT = Struct.new(:days)
  DAY_STRUCT = Struct.new(:day, :events, :css_classes)

  def initialize(date, events)
    @date = date
    @events = events
  end

  def weeks
    first = @date.beginning_of_month.beginning_of_week(START_DAY)
    last = @date.end_of_month.end_of_week(START_DAY)
    dates_in_groups = (first..last).to_a.in_groups_of(7)
    dates_in_groups.map do |dates|
      WEEK_STRUCT.new(dates.map { |day| format_day(day) })
    end
  end

  def format_day(day)
    DAY_STRUCT.new(day, day_events(day), date_classes(day))
  end

  def day_events(day)
    return [] if day.month != @date.month

    @events[day] || []
  end

  def date_classes(day)
    classes = []
    classes << "today" if day == Time.zone.today
    classes << "notmonth" if day.month != @date.month
    classes.empty? ? nil : classes.join(" ")
  end

  def name
    I18n.l(@date, format: "%B %Y").capitalize
  end
end
# rubocop:enable Metrics/BlockLength
