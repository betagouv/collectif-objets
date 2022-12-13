# frozen_string_literal: true

module Communes
  class FormulaireImprimablePolicy < BasePolicy
    alias formulaire_imprimable record
    delegate :commune, to: :formulaire_imprimable

    def show?
      user_commune? && !commune.completed?
    end
    alias enqueue_generate_pdf? show?

    private

    def user_commune?
      user.commune == commune
    end
  end
end
