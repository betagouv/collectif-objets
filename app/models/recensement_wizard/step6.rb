# frozen_string_literal: true

module RecensementWizard
  class Step6 < Base
    STEP_NUMBER = 6
    TITLE = "Commentaires"

    def permitted_params = %i[notes]
  end
end
