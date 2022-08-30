# frozen_string_literal: true

require "active_support/concern"

module Campaigns
  module ForceStepUpConcern
    extend ActiveSupport::Concern

    def can_force_start?
      return false if Rails.configuration.x.environment_specific_name == "production"

      (draft? || planned?) && communes.any? && safe_emails?
    end

    def can_force_step_up?
      return false if Rails.configuration.x.environment_specific_name == "production"

      ongoing? && next_step && communes.any? && safe_emails?
    end

    def safe_emails?
      communes.map(&:users).flatten.all?(&:safe_email?)
    end
  end
end
