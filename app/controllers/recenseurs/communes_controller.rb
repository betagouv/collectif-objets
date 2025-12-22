# frozen_string_literal: true

module Recenseurs
  class CommunesController < BaseController
    def index
      @pagy, @communes = pagy policy_scope(Commune).order(:departement_code, :nom)
      redirect_to [namespace, @communes.first] if @communes.load.size == 1
    end

    def show
      @commune = Commune.find(params[:id])
      authorize(@commune)
      @dossier = @commune.dossier
      if @commune.completed?
        redirect_to recenseurs_commune_completion_path(@commune)
      else
        @objets_list = objets_list
      end
    end

    private

    def objets_list
      Co::Communes::ObjetsList.new(
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

    def recensement_saved?
      params[:recensement_saved].present?
    end

    def display_only_next_objets?
      @dossier&.construction? && recensement_saved?
    end

    def active_nav_links = %w[Communes]
  end
end
