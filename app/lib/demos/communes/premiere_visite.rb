# frozen_string_literal: true

module Demos
  module Communes
    class PremiereVisite < Base
      def template = "communes/pages/premiere_visite"

      def perform
        @commune = build(:commune)
      end
    end
  end
end
