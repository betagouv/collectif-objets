# frozen_string_literal: true

module Recenseurs
  class BaseController < ApplicationController
    before_action :restrict_access
    before_action :warn_unless_accepted

    include Pundit::Authorization
    include NamespacedPolicies

    # rubocop:disable Rails/LexicallyScopedActionFilter
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
    # rubocop:enable Rails/LexicallyScopedActionFilter

    private

    def pundit_user
      # impersonating est à true quand tu incarnes en lecture seule. Il est à false si incarnation en écriture
      current_recenseur.impersonating =
        # Si connecté en tant qu'admin true_recenseur est nil, et current_recenseur est le recenseur incarné
        current_recenseur != true_recenseur &&
        # si n'existe pas -> lecture seule (par défaut)
        session[:recenseur_impersonate_write].blank?
      current_recenseur
    end

    def restrict_access
      return true if current_recenseur.present?

      redirect_to new_recenseur_session_path, alert: "Vous n'êtes pas connecté en tant que recenseur"
    end

    def warn_unless_accepted
      return if current_recenseur.nil? || current_recenseur.accepted?

      flash.now[:notice] = "Votre accès recenseur n'est pas autorisé à recenser actuellement."
    end
  end
end
