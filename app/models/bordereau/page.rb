# frozen_string_literal: true

module Bordereau
  class Page
    def initialize(bordereau)
      @bordereau = bordereau
    end

    private

    attr_reader :bordereau

    delegate :dossier, :document, :edifice, :commune, to: :bordereau
    delegate :define_grid, :grid, :image, :move_down, :text, :grid, :stroke_horizontal_rule, :table, to: :document
  end
end
