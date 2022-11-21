# frozen_string_literal: true

class DossierAccept
  attr_reader :dossier

  delegate :departement, to: :dossier

  def initialize(dossier:)
    @dossier = dossier
  end
end
