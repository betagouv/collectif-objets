# frozen_string_literal: true

class DossierReject
  attr_reader :dossier

  delegate :departement, to: :dossier

  def initialize(dossier:)
    @dossier = dossier
  end
end
