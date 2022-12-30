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
  class CommunesController < BaseController
    def current_user
      commune = build(:commune)
      build(:user, commune:)
    end

    def objets_index
      @commune = build(:commune)
      @objets_list ||= MockedObjetsList.new(@commune, 3.times.map { build(:objet) })
      render "communes/objets/index"
    end

    def objet_show
      @commune = build(:commune)
      @objet = build(:objet, commune: @commune)
      render "communes/objets/show"
    end

    def new_recensement
      @commune = build(:commune)
      @objet = build(:objet, commune: @commune)
      @recensement = build(:recensement, :empty, objet: @objet)
      render "communes/recensements/new"
    end

    # def show
    #   authorize(@objet)
    # end
  end
end
