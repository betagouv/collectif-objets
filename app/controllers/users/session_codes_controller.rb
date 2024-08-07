# frozen_string_literal: true

module Users
  class SessionCodesController < ApplicationController
    before_action :require_no_authentication
    before_action :redirect_mismatching_departement, only: :new

    def new
      if params[:code_insee].present?
        @commune = Commune.find_by(code_insee: params[:code_insee])
        @commune_user = @commune&.users&.first
        @no_user = !@commune_user
        @departement = @commune.departement
      elsif params[:departement].present?
        @departement = Departement.find(params[:departement])
      end
    end

    def create
      user = User.find_by(email: params[:email])
      if user.nil?
        return redirect_to \
          new_user_session_code_path,
          alert: "Erreur : l’email de la commune est incorrect"
      end

      session_code = user.session_code || user.create_session_code!
      UserMailer.with(session_code:).session_code_email.deliver_later
      redirect_to new_user_session_path(email: user.email)
    end

    protected

    def redirect_mismatching_departement
      return if params[:code_insee].blank? ||
                params[:departement].blank? ||
                params[:code_insee].start_with?(params[:departement])

      redirect_to new_user_session_code_path(departement: params[:departement])
    end
  end
end
