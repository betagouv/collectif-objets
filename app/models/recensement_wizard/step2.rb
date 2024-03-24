# frozen_string_literal: true

module RecensementWizard
  class Step2 < Base
    STEP_NUMBER = 2
    TITLE = "Précisions sur la localisation"

    attr_accessor :autre_edifice_checked

    validates :edifice_id,
              presence: { message: "Veuillez sélectionner un édifice ou \
                cocher la case ci-dessous si l'édifice n'est pas dans la liste." }

    validates \
      :edifice_nom,
      presence: {
        message: "Veuillez préciser le nom de l’édifice dans lequel l’objet a été déplacé"
      }, if: -> { autre_edifice? }

    def permitted_params = %i[edifice_id edifice_nom autre_edifice_checked]

    def assign_attributes(attributes)
      super

      recensement.edifice_nom = nil unless autre_edifice?
    end

    def autre_edifice?
      edifice_id.present? && edifice_id.zero?
    end
  end
end
