# frozen_string_literal: true

module Sanity
  class RemoveDeprecatedEdificesJob < ApplicationJob
    def perform
      edifices = Edifice.where.missing(:objets).where(merimee_REF: nil)
      GoodJob.logger.info "will delete #{edifices.count} edifices without any objets nor merimee_REF ..."
      edifices.each(&:destroy!)
      GoodJob.logger.info "done, there are now #{Edifice.count} edifices in the database"
    end
  end
end
