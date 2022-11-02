# frozen_string_literal: true

module Conservateurs
  class ObjetsController < BaseController
    before_action :set_objet

    def show
      if @objet.commune.inactive? && @objet.current_recensement.nil?
        @cta = :recenser
      elsif @objet.current_recensement.author == current_conservateur
        @cta = :edit_recensement
      elsif @objet.current_recensement.author.is_a? user
        @cta = :analyser
      end
    end

    protected

    def set_objet
      @objet = Objet.find(params[:id])
      authorize(@objet)
    end
  end
end
