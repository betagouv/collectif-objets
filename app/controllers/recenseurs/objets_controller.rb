# frozen_string_literal: true

module Recenseurs
  class ObjetsController < BaseController
    before_action :set_commune, :set_dossier
    before_action :set_objet, only: [:show]

    def index
      @objets_list = objets_list
      return unless display_only_next_objets?

      render(:recensement_saved)
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
        exclude_recensed: display_only_next_objets?,
        exclude_ids: display_only_next_objets? ? [previous_objet&.id].compact : [],
        edifice: display_only_next_objets? ? previous_objet&.edifice : nil
      )
    end

    def previous_objet
      return nil if params[:objet_id].blank?

      @previous_objet ||= Objet.find(params[:objet_id])
    end

    def active_nav_links = %w[Recensement]

    def display_only_next_objets?
      @dossier&.construction? && recensement_saved?
    end
  end
end
