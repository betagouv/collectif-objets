# frozen_string_literal: true

module Sanity
  class RemoveOldSessionCodesJob < ApplicationJob
    def perform
      session_codes = SessionCode.where("created_at < ?", 1.month.ago)
      GoodJob.logger.info "will delete #{session_codes.count} session_codes that are older than a month"
      session_codes.each(&:destroy!)
      GoodJob.logger.info "done, there are now #{SessionCode.count} session_codes in the database"
    end
  end
end
