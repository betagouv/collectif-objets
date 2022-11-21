# frozen_string_literal: true

class FormulaireImprimable
  attr_reader :commune

  def initialize(commune:)
    @commune = commune
  end

  def enqueue_generate_pdf
    return if \
      commune.formulaire.attached? &&
      commune.formulaire_updated_at &&
      commune.formulaire_updated_at >= commune.updated_at

    commune.formulaire&.purge
    GenerateFormulaireJob.perform_async(commune.id)
  end
end
