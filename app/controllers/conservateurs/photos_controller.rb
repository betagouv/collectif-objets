# frozen_string_literal: true

module Conservateurs
  class PhotosController < BaseController
    layout "gallery"
    before_action :set_recensement, :set_dossier, :set_analyse, :set_objet, :set_gallery, :set_photo
    before_action :skip_authorization, only: %i[show]

    def show
      if @index.positive?
        previous_blob_id = @gallery.photos[@index - 1].blob_id
        @previous_link = conservateurs_objet_recensement_photo_path(@objet, @recensement, previous_blob_id)
      end
      if @index + 1 < @gallery.count
        next_blob_id = @gallery.photos[@index + 1].blob_id
        @next_link = conservateurs_objet_recensement_photo_path(@objet, @recensement, next_blob_id)
      end
    end

    protected

    def set_gallery
      @gallery = Gallery.from_recensement(@recensement)
    end

    def set_photo
      @index = @gallery.photos.find_index { _1.blob_id == params[:id].to_i }
      @photo = @gallery.photos[@index]
    end

    def set_recensement
      @recensement = Recensement.includes(dossier: [:commune]).find(params[:recensement_id])
      @recensement_presenter = RecensementPresenter.new(@recensement) if @recensement
    end

    def set_analyse
      @analyse = Analyse.new(recensement: @recensement)
    end

    def set_objet
      @objet = @recensement.objet
    end

    def set_dossier
      @dossier = @recensement.dossier
    end

    def active_nav_links = ["Mes départements", @dossier.departement.to_s]
  end
end
