# frozen_string_literal: true

require "open-uri"

# rubocop:disable Metrics/AbcSize
module Co
  module Pdf
    module Formulaire
      class PrawnView
        include Co::Pdf::BasePrawnViewConcern
        include Co::Pdf::Formulaire::QuestionsConcern

        LEFT_LINE_COLOR = "6777c7"

        def initialize(commune)
          @commune = commune
          set_default_font
          @grid = define_grid(columns: 9, rows: 10, gutter: 5)
          # grid.show_all
          display_content
        end

        def display_content
          @commune.objets.each.with_index do |objet, index|
            display_objet(objet)
            start_new_page unless index == @commune.objets.count - 1
          end
        end

        def display_objet(objet)
          display_logos
          display_pop_infos(objet)
          display_pop_photo(objet)
          display_title
          display_left_line
          display_questions(objet)
        end

        def display_logos
          grid([0, 0], [1, 1]).bounding_box do
            image "public/ministere-culture.png", width: 100
            move_down 10
            text "<b>Collectif Objets</b>", size: 12, inline_format: true
          end
        end

        def display_pop_infos(objet)
          grid([0, 2], [1, 5]).bounding_box do
            text "<b>#{objet.nom}</b>", inline_format: true, align: :right
            text objet.palissy_REF, color: "666666", align: :right
            text(objet.palissy_EDIF, align: :right) if objet.palissy_EDIF.present?
            text(objet.palissy_EMPL, align: :right) if objet.palissy_EMPL.present?
          end
        end

        def display_pop_photo(objet)
          grid([0, 6], [1, 8]).bounding_box do
            image(
              pop_photo_io(objet),
              fit: [bounds.width, bounds.height],
              position: :center
            )
          end
        end

        def pop_photo_io(objet)
          return URI.parse(objet.palissy_photos.first.url).open if objet.palissy_photos.any?

          Rails.root.join "app/frontend/images/illustrations/photo-manquante.png"
        end

        def display_title
          grid([2, 0], [3, 8]).bounding_box do
            move_down 20
            text "<b>Formulaire de recensement</b>", inline_format: true, size: 24
            text(
              "<i>Le guide de recensement vous donne toutes les clés pour répondre aux questions. " \
              "Téléchargez le sur <u><link href='https://collectif-objets.beta.gouv.fr/guide'>collectif-objets.beta.gouv.fr/guide</link></u></i>",
              inline_format: true
            )
          end
        end

        def display_left_line
          display_left_dashed_line
          display_left_bullets
        end

        def display_left_dashed_line
          dash 3
          stroke_color(LEFT_LINE_COLOR)
          grid([4, 0], [8, 0]).bounding_box do
            stroke_line([(bounds.width / 2), cursor], [(bounds.width / 2), bounds.bottom - grid.gutter])
          end
          stroke_color "000000"
          undash
        end

        def display_left_bullets
          fill_color(LEFT_LINE_COLOR)
          [4, 5, 6, 7, 8, 9].each do |index|
            grid([index, 0], [index, 0]).bounding_box do
              fill_circle [bounds.width / 2, bounds.top - 5], 5
            end
          end
          fill_color "000000"
        end
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
