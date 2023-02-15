# frozen_string_literal: true

module Demos
  module Communes
    class RecensementStep6 < Base
      def template = "communes/recensements/edit"

      def perform
        @objet = build(:objet, commune:)
        @recensement = build(:recensement, objet: @objet)
        @wizard = RecensementWizard::Base.build_for(6, @recensement)
      end
    end
  end
end
