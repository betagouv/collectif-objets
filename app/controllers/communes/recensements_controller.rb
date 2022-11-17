# frozen_string_literal: true

module Communes
  class RecensementsController < BaseController
    before_action :set_objet
    before_action :set_new_recensement, only: %i[new create]
    before_action :set_recensement, only: %i[edit update]
    before_action :authorize_recensement

    def new
      @recensement = Recensement.new(objet: @objet, recensable: "true")
    end

    def edit
      @recensement.confirmation_pas_de_photos = true if @recensement.photos.empty?
    end

    def create
      result = Communes::CreateRecensementService
        .new(params: recensement_params, objet: @objet, user: current_user)
        .perform
      if result.success?
        redirect_to commune_objets_path(@objet.commune, recensement_saved: true, objet_id: @objet.id)
      else
        @recensement = result.recensement
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @recensement.update(recensement_params)
        redirect_to commune_objets_path(@objet.commune, recensement_saved: true, objet_id: @objet.id)
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
    end

    def set_new_recensement
      @recensement = Recensement.new(objet: @objet)
    end

    def recensement_params
      @recensement_params ||= Co::Recensements::ParamsParser.new(params).parse
    end

    def authorize_recensement
      authorize(@recensement)
    end
  end
end
