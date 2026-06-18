# frozen_string_literal: true

module Recenseurs
  class SessionCodesController < ApplicationController
    before_action :require_no_authentication
    before_action :set_recenseur

    def new; end

    def create
      if @recenseur.persisted?
        session_code = @recenseur.session_code || @recenseur.create_session_code!
        RecenseurMailer.with(session_code:).session_code.deliver_later
        redirect_to new_recenseur_session_path(email: @recenseur.email)
      else
        @recenseur.errors.add(:email, :not_found, message: "ne correspond à aucun compte recenseur.")
        render :new, status: :unprocessable_content
      end
    end

    private

    def set_recenseur
      @recenseur = params[:email].present? ? Recenseur.find_or_initialize_by(email: params[:email]) : Recenseur.new
    end
  end
end
