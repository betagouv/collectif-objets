# frozen_string_literal: true

module Demos
  module Communes
    class RecensementStep2 < Base
      def template = "communes/recensements/edit"

      def perform
        @objet = build(:objet, commune:)
        @recensement = build(:recensement, :empty, objet: @objet)
        @wizard = RecensementWizard::Base.build_for(2, @recensement)
      end
    end
  end
end
