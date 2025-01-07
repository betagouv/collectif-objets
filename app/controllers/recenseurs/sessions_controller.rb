# frozen_string_literal: true

module Recenseurs
  class SessionsController < Devise::SessionsController
    prepend_before_action :require_no_authentication, only: [:new, :create]

    def new
      @recenseur = params[:email].present? ? Recenseur.find_or_initialize_by(email: params[:email]) : Recenseur.new
      @errors = {}
    end

    def create
      @recenseur, @errors = Recenseur.authenticate_by(**params.permit(:email, :code).to_h.symbolize_keys)
      if @recenseur && sign_in(@recenseur)
        redirect_to after_sign_in_path_for(@recenseur), notice: "Vous êtes maintenant connecté(e)"
      else
        @recenseur = Recenseur.new(email: params[:email])
        render :new, status: :unprocessable_content
      end
    end
  end
end
