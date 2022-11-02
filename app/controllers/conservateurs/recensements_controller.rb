# frozen_string_literal: true

module Conservateurs
  class RecensementsController < BaseController
    before_action :set_objet
    before_action :set_recensement, only: %i[edit update]

    def new
      @recensement = Recensement.new(objet: @objet, recensable: "true")
      authorize(@recensement)
    end

    def edit
      @recensement.confirmation_sur_place = true
      @recensement.confirmation_pas_de_photos = true if @recensement.photos.empty?
      authorize(@recensement)
    end

    def create
      service = Conservateurs::CreateRecensementService
        .new(params: recensement_params, objet: @objet, conservateur: current_conservateur)
      authorize(service.recensement)
      service.perform
      if service.success?
        redirect_to conservateurs_commune_path(@objet.commune, notice: "Recensement enregistré !")
      else
        @recensement = service.recensement
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @recensement.confirmation_sur_place = true
      if @recensement.update(recensement_params)
        redirect_to conservateurs_commune_path(@objet.commune, notice: "Recensement enregistré !")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    protected

    def set_objet
      @objet = Objet.find(params[:objet_id])
    end

    def set_recensement
      @recensement = Recensement.find(params[:id])
      authorize(@recensement)
    end

    def recensement_params
      @recensement_params ||= Co::Recensements::ParamsParser.new(params).parse
    end
  end
end
