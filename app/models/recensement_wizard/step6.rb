# frozen_string_literal: true

module RecensementWizard
  class Step6 < Base
    STEP_NUMBER = 6
    TITLE = "Récapitulatif"

    def update(_params)
      recensement.complete
    end

    def after_success_path
      commune_objets_path(commune, recensement_saved: true, objet_id: objet.id)
    end
  end
end
