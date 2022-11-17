# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    before_action :restrict_connected_as_commune
    before_action :set_objet, only: [:show]
    before_action :restrict_own_commune, only: [:show]

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
        edifice_nom: previous_objet&.edifice_nom
      )
    end

    def previous_objet
      return nil if params[:objet_id].blank?

      @previous_objet ||= Objet.find(params[:objet_id])
    end

    def restrict_connected_as_commune
      return true if current_user.present?

      redirect_to root_path, alert: "Vous n'êtes pas connecté en tant que commune"
    end

    def restrict_own_commune
      return true if current_user&.commune == @objet.commune

      redirect_to root_path, alert: "Cet objet n'appartient pas à votre commune"
    end
  end
end
