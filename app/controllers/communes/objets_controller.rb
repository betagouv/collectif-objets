# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    before_action :set_objet, only: [:show]

    def index
      @objets_list = objets_list
      return unless recensement_saved?

      render(:recensement_saved) if @dossier.construction?
      render(:recensement_saved_after_reject) if @dossier.rejected?
    end

    def show
      authorize(@objet)
    end

    def index_print
      raise if @commune.blank?

      @objets = policy_scope(Objet).where(commune: @commune)
    end

    private

    def set_objet
      @objet = Objet.find(params[:id])
    end

    def recensement_saved?
      params[:recensement_saved].present?
    end

    def objets_list
      @objets_list ||= Co::Communes::ObjetsList.new(
        @commune,
        scoped_objets: policy_scope(Objet),
        exclude_recensed: recensement_saved?,
        exclude_ids: [previous_objet&.id].compact,
        edifice: previous_objet&.edifice
      )
    end

    def previous_objet
      return nil if params[:objet_id].blank?

      @previous_objet ||= Objet.find(params[:objet_id])
    end
  end
end
