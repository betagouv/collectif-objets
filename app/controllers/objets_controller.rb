# frozen_string_literal: true

class ObjetsController < ApplicationController
  def index
    redirect_to Commune.find_by!(code_insee: params[:commune_code_insee])
  end

  def show
    @objet = Objet.find(params[:id])
    redirect_to root_path, alert: "Cet objet n'est lié à aucune commune" unless @objet.commune
  end
end
