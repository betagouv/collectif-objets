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
      # impersonating est à true quand tu incarnes en lecture seule. Il est à false si incarnation en écriture
      current_conservateur.impersonating =
        # Si connecté en tant qu'admin true_conservateur est nil, et current_conservateur est le conservateur incarné
        current_conservateur != true_conservateur &&
        # si n'existe pas -> lecture seule (par défaut)
        session[:conservateur_impersonate_write].blank?
      current_conservateur
    end

    def restrict_access
      return true if current_conservateur.present?

      redirect_to new_conservateur_session_path, alert: "Vous n'êtes pas connecté en tant que conservateur"
    end

    def policy_scope(scope)
      super([:conservateurs, scope])
    end

    def authorize(record, query = nil)
      super([:conservateurs, record], query)
    end
  end
end
