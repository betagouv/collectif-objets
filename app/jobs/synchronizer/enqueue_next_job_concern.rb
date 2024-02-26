# frozen_string_literal: true

require "csv"

module Synchronizer
  module EnqueueNextJobConcern
    extend ActiveSupport::Concern

    ENQUEUE_ORDER = %w[
      Synchronizer::Objets::SynchronizeAllJob
      Synchronizer::Communes::SynchronizeAllJob
      Synchronizer::Edifices::SynchronizeAllJob
      Synchronizer::Photos::SynchronizeAllJob
    ].freeze

    def enqueue_next_job
      next_job_class = ENQUEUE_ORDER[ENQUEUE_ORDER.index(self.class.name) + 1]
      return if next_job_class.nil?

      next_job_class.constantize.perform_later(enqueue_next_job_after_success: true)
    end
  end
end
