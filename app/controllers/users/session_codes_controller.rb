# frozen_string_literal: true

module Users
  class SessionCodesController < ApplicationController
    before_action :require_no_authentication
    before_action :set_commune_and_departement
    before_action :redirect_mismatching_departement, only: :new

    def new
      @commune_user = @commune&.users&.first
      @no_user = @commune && !@commune_user
      @magic_link = request.path == "/magic-authentication"
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

    def set_commune_and_departement
      code = params[:departement].to_s
      code_insee = params[:code_insee].to_s

      @departement = Departement.find_by(code:) if code.present?
      @commune = Commune.find_by(code_insee:) if code_insee.present?
    end

    def redirect_mismatching_departement
      return unless @commune && @departement
      return if @commune.code_insee.start_with?(@departement.code)

      redirect_to new_user_session_code_path(departement: @departement.code)
    end
  end
end
