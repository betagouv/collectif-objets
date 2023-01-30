# frozen_string_literal: true

module Demos
  module Communes
    class ObjetShow < Base
      def template = "communes/objets/show"

      def perform
        @objet = build(:objet, commune:)
      end
    end
  end
end
