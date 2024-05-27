# frozen_string_literal: true

class ObjetsController < ApplicationController
  def show
    @objet = Objet.find(params[:id])
    redirect_to root_path, alert: "Cet objet n'est lié à aucune commune" unless @objet.commune
  end
end
