# frozen_string_literal: true

module Communes
  class FormulairesController < BaseController
    before_action :set_formulaire_and_authorize
    before_action :enqueue_generate_pdf

    def show; end

    def enqueue_generate_pdf
      @formulaire_imprimable.enqueue_generate_pdf
    end

    private

    def set_formulaire_and_authorize
      @formulaire_imprimable = FormulaireImprimable.new(commune: @commune)
      authorize(@formulaire_imprimable)
    end
  end
end
