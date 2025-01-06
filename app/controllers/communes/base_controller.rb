# frozen_string_literal: true

module Communes
  class BaseController < ApplicationController
    include Pundit::Authorization
    include NamespacedPolicies

    # rubocop:disable Rails/LexicallyScopedActionFilter
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    # rubocop:enable Rails/LexicallyScopedActionFilter

    before_action :authenticate_user!, unless: -> { impersonating_user? }
    before_action :set_commune, :set_dossier, :restrict_access

    protected

    def pundit_user
      current_user.impersonating = current_user != true_user && session[:user_impersonate_write].blank?
      current_user
    end

    def set_commune
      @commune = Commune.find(params[:commune_id])
    end

    def set_dossier
      @dossier = @commune.dossier # can be nil
    end

    def restrict_access
      return true if current_user.commune == @commune

      redirect_to root_path, alert: "Vous n'êtes pas connecté avec le compte de la commune #{@commune}"
    end
  end
end
