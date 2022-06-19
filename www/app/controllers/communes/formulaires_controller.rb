# frozen_string_literal: true

module Communes
  class FormulairesController < BaseController
    before_action :enqueue_generate_pdf

    def show; end

    def enqueue_generate_pdf
      return if @commune.formulaire.attached?

      GenerateFormulaireJob.perform_async(@commune.id)
    end
  end
end
