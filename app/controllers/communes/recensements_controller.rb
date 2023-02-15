# frozen_string_literal: true

module Communes
  class RecensementsController < BaseController
    before_action :set_objet
    before_action :set_recensement, only: %i[edit update destroy]
    before_action :set_wizard, only: %i[edit update]

    def edit
      @modal = params[:modal]
    end

    def create
      @recensement = Recensement.new(objet: @objet, user: current_user, status: "draft")
      authorize(@recensement)
      if @recensement.save
        redirect_to edit_commune_objet_recensement_path(@recensement.commune, @objet, @recensement, step: 1)
      else
        redirect_to commune_objet_path(objet.commune, objet),
                    alert: "Une erreur est survenue : #{@recensement.errors.full_messages.join}"
      end
    end

    def update
      if @wizard.update(params_wizard)
        redirect_to @wizard.after_success_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @recensement.destroy
        redirect_to \
          commune_objet_path(@recensement.commune, @recensement.objet),
          success: "Recensement supprimé"
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
      authorize @recensement
    end

    def set_wizard
      step = params[:step] || (@recensement.draft? ? 1 : 6)
      @wizard = RecensementWizard::Base.build_for(step, @recensement)
      @wizard.assign_attributes(params_wizard)
    end

    def params_wizard
      params[:wizard].present? ? params.require(:wizard).permit(*@wizard.permitted_params) : {}
    end

    # def recensement_params
    #   params.require(:recensement).permit(*PARTS, :edifice_nom).merge(user: current_user)
    # end
  end
end
