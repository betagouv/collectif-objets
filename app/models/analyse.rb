# frozen_string_literal: true

class Analyse
  attr_reader :recensement

  delegate :dossier, :commune, :departement, to: :recensement

  def initialize(recensement:)
    @recensement = recensement
  end
end
