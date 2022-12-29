# frozen_string_literal: true

class MockedObjetsList
  attr_reader :commune, :objets

  def initialize(commune, objets)
    @commune = commune
    @objets = objets
  end

  def edifice = nil
  def edifices = nil
  def group_by_edifice? = false

  delegate :count, :any?, to: :objets
end

module Demo
  module Communes
    class ObjetsController < BaseController
      def index
        @commune = build(:commune)
        @objets_list ||= MockedObjetsList.new(@commune, 3.times.map { build(:objet) })
        render "communes/objets/index"
      end

      def show
        @commune = build(:commune)
        @objet = build(:objet, commune: @commune)
        render "communes/objets/show"
      end

      def index_recensement_saved
        # render(:recensement_saved) if @dossier.construction?
        # render(:recensement_saved_after_reject) if @dossier.rejected?
      end

      # def show
      #   authorize(@objet)
      # end
    end
  end
end
