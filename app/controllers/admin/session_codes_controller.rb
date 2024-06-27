# frozen_string_literal: true

module Admin
  class SessionCodesController < BaseController
    def index
      @total = SessionCode.count
      @limit = 10
      @offset = params.fetch(:offset, 0).to_i
      @session_codes = SessionCode.includes(:commune).order(created_at: :desc).limit(@limit).offset(@offset * @limit)
    end

    private

    def active_nav_links = ["Administration"]
  end
end
