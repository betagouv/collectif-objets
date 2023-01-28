# frozen_string_literal: true

module Demos
  module Communes
    class CompletionShow < Base
      def template = "communes/completions/show"
      def default_variant = "with_photos"

      def perform
        @dossier = build(:dossier, :submitted, notes_communes: "Voici les recensements demandés", commune:)
        @objets = [
          build(
            :objet, :with_palissy_photo, :with_recensement_with_photos_mocked,
            palissy_photo_number: 1,
            recensement_photos_count: 1, recensement_photos_start_number: 1,
            commune:
          ),
          build(
            :objet, :with_palissy_photo, :with_recensement_with_photos_mocked,
            palissy_photo_number: 2,
            recensement_photos_count: 3, recensement_photos_start_number: 2,
            commune:
          )
        ]
      end
    end
  end
end
