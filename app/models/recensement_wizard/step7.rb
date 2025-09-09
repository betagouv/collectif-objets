# frozen_string_literal: true

module RecensementWizard
  class Step7 < Base
    TITLE = "Récapitulatif"

    def update(_params)
      return false unless recensement.valid?

      recensement.completed? || recensement.complete!
    end

    def after_success_path
      if recenseur?
        commune_path(recensement_saved: true)
      else
        commune_objets_path(commune, recensement_saved: true, objet_id: objet.id)
      end
    end
  end
end
