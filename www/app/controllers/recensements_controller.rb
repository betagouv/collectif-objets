# frozen_string_literal: true

class RecensementsController < ApplicationController
  before_action :restrict_access

  def new
    @recensement = Recensement.new(objet:, recensable: "true")
  end

  def edit
    @recensement = Recensement.find(params[:id])
    @recensement.confirmation = true
    @recensement.skip_photos = true if @recensement.photos.empty?
  end

  def create
    @recensement = Recensement.new(recensable: "true", **recensement_params_parsed, objet:)
    @recensement.confirmation = recensement_params[:confirmation].present?
    if @recensement.save
      redirect_to objet_path(objet), notice: "Le recensement a bien été enregistré !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @recensement = Recensement.find(params[:id])
    @recensement.confirmation = true
    if @recensement.update(recensement_params_parsed)
      redirect_to objet_path(objet), notice: "Le recensement a bien été mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def objet
    @objet ||= Objet.find(params[:objet_id])
  end

  def recensement_params
    params
      .require(:recensement)
      .permit(
        :confirmation, :localisation, :recensable, :edifice_nom, :etat_sanitaire,
        :etat_sanitaire_edifice, :securisation, :notes, :skip_photos, photos: []
      )
  end

  def recensement_params_parsed
    recensement_params.merge(recensable:
        recensement_params[:recensable].blank? ||
        recensement_params[:recensable] == "true")
  end

  def restrict_access
    return true if current_user&.commune == objet&.commune

    redirect_to objet_path(objet), alert: "Vous n'êtes pas autorisé à recenser cet objet"
  end
end
