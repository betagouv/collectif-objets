# frozen_string_literal: true

module RecensementWizard
  class Step5 < Base
    STEP_NUMBER = 5
    TITLE = "Commentaires"

    def permitted_params = %i[notes]
  end
end
