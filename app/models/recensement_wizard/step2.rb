# frozen_string_literal: true

module RecensementWizard
  class Step2 < Base
    STEP_NUMBER = 2
    TITLE = "Précisions sur la localisation"

    def permitted_params = %i[edifice_id edifice_nom]
  end
end
