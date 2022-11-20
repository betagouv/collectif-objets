# frozen_string_literal: true

module Conservateurs
  class BaseController < ApplicationController
    before_action :restrict_access

    include Pundit::Authorization

    # rubocop:disable Rails/LexicallyScopedActionFilter
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    # rubocop:enable Rails/LexicallyScopedActionFilter

    private

    def pundit_user
      current_conservateur
    end

    def restrict_access
      return true if current_conservateur.present?

      redirect_to root_path, alert: "Vous n'êtes pas identifié en tant que conservateur"
    end

    def policy_scope(scope)
      super([:conservateurs, scope])
    end

    def authorize(record, query = nil)
      super([:conservateurs, record], query)
    end
  end
end
