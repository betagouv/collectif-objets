# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    before_action :set_objets

    def index
      return unless recensement_saved?

      render(:recensement_saved) if @dossier.construction?
      render(:recensement_saved_after_reject) if @dossier.rejected?
    end

    def index_print
      raise if @commune.blank?

      @objets = Objet.where(commune: @commune)
    end

    private

    def recensement_saved?
      params[:recensement_saved].present?
    end

    def set_objets
      @objets_list = Co::Communes::ObjetsList.new(
        @commune,
        exclude_recensed: recensement_saved?,
        exclude_ids: [previous_objet&.id].compact,
        edifice_nom: previous_objet&.edifice_nom
      )
    end

    def previous_objet
      return nil if params[:objet_id].blank?

      @previous_objet ||= Objet.find(params[:objet_id])
    end
  end
end
