# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :restrict_access

    layout "admin"

    protected

    def restrict_access
      return true if current_admin_user.present?

      redirect_to root_path, alert: "Vous n'êtes pas connecté en tant qu'admin"
    end
  end
end
