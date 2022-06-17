# frozen_string_literal: true

module Communes
  class RecensementFormsPdfController < BaseController
    def create
      GenerateRecensementFormsPdfJob.perform_async(@commune.id) unless @commune.recensement_forms_pdf.attached?
    end
  end
end
