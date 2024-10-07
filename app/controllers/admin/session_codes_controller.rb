# frozen_string_literal: true

module Admin
  class SessionCodesController < BaseController
    def index
      @total = SessionCode.count
      @pagy, @session_codes = pagy SessionCode.includes(:commune).order(created_at: :desc), limit: 10
    end

    private

    def active_nav_links = ["Administration"]
  end
end
