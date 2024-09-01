# frozen_string_literal: true

class DepartementActiviteJob < ApplicationJob
  queue_as :default

  class << self
    def date_start = 1.week.ago.at_beginning_of_week
    def date_end = date_start.at_end_of_week
    def date_range = date_start..date_end
  end

  delegate :date_start, :date_end, :date_range, to: :class

  def perform
    Departement.with_activity_in(date_range).each do |departement_code, conservateur_ids|
      conservateur_ids.each do |conservateur_id|
        ConservateurMailer.with(conservateur_id:, departement_code:, date_start:, date_end:)
          .activite_email.deliver_later
      end
    end
  end
end
