# frozen_string_literal: true

module Demos
  module Communes
    class NewRecensement < Base
      def template = "communes/recensements/new"

      def perform
        @commune = build(:commune)
        @objet = build(:objet, commune: @commune)
        @recensement = build(:recensement, :empty, objet: @objet)
      end
    end
  end
end
