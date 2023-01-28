# frozen_string_literal: true

module Demos
  module Communes
    class NewRecensement < Base
      def template = "communes/recensements/new"

      def perform
        @objet = build(:objet, commune:)
        @recensement = build(:recensement, :empty, objet: @objet)
      end
    end
  end
end
