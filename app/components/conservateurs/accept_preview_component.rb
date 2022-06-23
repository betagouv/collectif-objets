# frozen_string_literal: true

module Conservateurs
  class AcceptPreviewComponent < ViewComponent::Base
    attr_reader :dossier

    def initialize(dossier:)
      @dossier = dossier
      super
    end

    def mail
      @mail ||= UserMailerPreview.new.dossier_accepted_email(dossier)
    end
  end
end
