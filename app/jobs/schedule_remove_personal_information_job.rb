# frozen_string_literal: true

class ScheduleRemovePersonalInformationJob < ApplicationJob
  queue_as :default

  class << self
    def dossiers
      Dossier.where(created_at: ..6.years.ago)
             .where.not(recenseur: [nil, ""])
    end
  end

  delegate :dossiers, to: :class

  def perform
    dossiers.pluck(:id).each { RemovePersonalInformationJob.perform_later(_1) }
  end
end
