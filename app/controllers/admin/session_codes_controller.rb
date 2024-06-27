# frozen_string_literal: true

module Admin
  class SessionCodesController < BaseController
    def index
      @total = SessionCode.count
    end

    private

    def active_nav_links = ["Administration"]
  end
end
