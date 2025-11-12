# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @active_nav_links = ["Administration"]
    end
  end
end
