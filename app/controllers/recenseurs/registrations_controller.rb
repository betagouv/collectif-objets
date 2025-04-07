# frozen_string_literal: true

module Recenseurs
  class RegistrationsController < BaseController
    before_action :set_recenseur
    skip_after_action :verify_authorized

    # GET /recenseurs/registration/edit
    def edit; end

    # PATCH/PUT /recenseurs/registration
    def update
      @recenseur.assign_attributes(recenseur_params)
      @recenseur.status = :pending if @recenseur.email_changed? && @recenseur.accepted?
      if @recenseur.save
        redirect_to recenseurs_communes_path, notice: "Préférences modifiées.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /conservateurs/recenseurs/1
    def destroy
      @recenseur.destroy
      sign_out @recenseur
      redirect_to root_path, notice: "Votre accès recenseur a bien été supprimé.", status: :see_other
    end

    private

    def set_recenseur = @recenseur = current_recenseur

    def recenseur_params
      params.require(:recenseur).permit(:email, :nom)
    end
  end
end
