# frozen_string_literal: true

module Conservateurs
  class DossierAcceptPolicy < BasePolicy
    alias dossier_accept record

    delegate :dossier, to: :dossier_accept

    def create?
      dossier.submitted? &&
        dossier.commune.completed? &&
        dossier.recensements.not_analysed.empty?
    end
    alias update? create?
  end
end
