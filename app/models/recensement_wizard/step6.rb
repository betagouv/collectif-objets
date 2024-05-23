# frozen_string_literal: true

module RecensementWizard
  class Step6 < Base
    TITLE = "Commentaires"

    def permitted_params = %i[notes]
  end
end
