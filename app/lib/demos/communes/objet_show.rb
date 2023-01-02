# frozen_string_literal: true

module Demos
  module Communes
    class ObjetShow < Base
      def template = "communes/objets/show"

      def perform
        @commune = build(:commune)
        @objet = build(:objet, commune: @commune)
      end
    end
  end
end
