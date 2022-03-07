# frozen_string_literal: true

class RecensementsController < ApplicationController
  before_action :set_objet, :restrict_commune
  before_action :restrict_recensable, only: %i[new create]
  before_action :set_recensement, :restrict_editable, only: %i[edit update]

  def new
    @recensement = Recensement.new(objet: @objet, recensable: "true")
  end

  def edit
    @recensement.confirmation = true
    @recensement.skip_photos = true if @recensement.photos.empty?
  end

  def create
    @recensement = Recensement.new(recensable: "true", **recensement_params_parsed, objet: @objet)
    @recensement.confirmation = recensement_params[:confirmation].present?
    if @recensement.save
      redirect_to objet_path(@objet), notice: "Le recensement a bien été enregistré !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @recensement.confirmation = true
    if @recensement.update(recensement_params_parsed)
      redirect_to objet_path(@objet), notice: "Le recensement a bien été mis à jour"
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

  def restrict_commune
    return true if current_user&.commune == @objet.commune

    redirect_to objet_path(@objet), alert: "Vous n'êtes pas autorisé à recenser cet objet"
  end

  def restrict_recensable
    return true if @objet.recensable?

    redirect_to objet_path(@objet), alert: "Le recensement de votre commune est déjà terminé."
  end

  def restrict_editable
    return true if @recensement.editable?

    redirect_to objet_path(@objet), alert: "Ce recensement ne peut plus être édité."
  end
end
