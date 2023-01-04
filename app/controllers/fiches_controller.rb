# frozen_string_literal: true

class FichesController < ApplicationController
  def index
    @fiches = Fiche.load_all
  end

  def show
    raise ArgumentError if Fiche.all_ids.exclude? params[:id]

    @fiche = Fiche.load_from_id(params[:id])
  end
end
