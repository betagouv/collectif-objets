# frozen_string_literal: true

module Communes
  class RecensementFormsPdfDownloadComponent < ViewComponent::Base
    include Turbo::StreamsHelper

    attr_reader :commune

    def initialize(commune)
      @commune = commune
      super
    end

    def pdf
      @commune.recensement_forms_pdf
    end

    def downloadable?
      pdf.attached?
    end
  end
end
