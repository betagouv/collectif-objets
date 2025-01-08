# frozen_string_literal: true

module Recenseurs
  class OptoutsController < ApplicationController
    before_action :set_recenseur

    # GET /recenseurs/optout/:token
    def new; end

    # GET /recenseurs/optout
    def destroy
      if @recenseur.nil?
        render :new, status: :unprocessable_content, alert: "Ce lien de désinscription n’est plus valide."
      elsif @recenseur.optout?
        redirect_to root_path, alert: "L'adresse #{@recenseur.email} est déjà désinscrite."
      elsif @recenseur.optout!
        redirect_to root_path, notice: "Entendu, nous n'enverrons plus de mails à l'adresse #{@recenseur.email}."
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def set_recenseur
      @recenseur = Recenseur.find_by_token_for(:optout, params[:token])
    end
  end
end
