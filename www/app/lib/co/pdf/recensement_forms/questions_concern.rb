# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize
module Co
  module Pdf
    module RecensementForms
      module QuestionsConcern
        extend ActiveSupport::Concern

        CHECKBOX_WIDTH = 16
        CHECKBOX_HEIGHT = 16
        GAP = 10
        TEXTBOX_HEIGHT = 30

        def display_questions(objet)
          display_question_photo
          display_question_localisation1(objet)
          display_question_localisation2
          display_question_etat_edifice
          display_question_etat_objet
          display_question_securisation
        end

        def display_question_photo
          grid([4, 1], [4, 8]).bounding_box do
            top = cursor
            image(
              "app/assets/images/camera-fill.png",
              width: 25,
              at: [0, top]
            )
            text_box(
              "<b>Prenez des photos de l'objet</b>:" \
              "une vue de face, de profil et si nécessaire un zoom sur un détail qui vous questionne",
              inline_format: true,
              at: [40, top]
            )
          end
        end

        def display_question_localisation1(objet)
          grid([5, 1], [5, 8]).bounding_box do
            text(
              "<b>Cet objet est-il bien présent dans l'édifice #{objet.palissy_EDIF}",
              inline_format: true
            )
            y = cursor
            checkbox("Oui")
            checkbox("Non", at: [(@grid.column_width + @grid.gutter) * 2, y])
          end
        end

        def display_question_localisation2
          grid([6, 1], [6, 8]).bounding_box do
            text(
              "<b>Sinon, connaissez-vous la localisation de cet objet</b>",
              inline_format: true
            )
            fill_color "eeeeee"
            stroke_color "333333"
            fill_rectangle [0, cursor], bounds.width, TEXTBOX_HEIGHT
            stroke_line([0, cursor - TEXTBOX_HEIGHT], [bounds.right, cursor - TEXTBOX_HEIGHT - 2])
            fill_color "000000"
            stroke_color "000000"
          end
        end

        def display_question_etat_edifice
          grid([7, 1], [7, 8]).bounding_box do
            text(
              "<b>Comment évaluez-vous l'état sanitaire de l'édifice à proximité de l'objet ?</b>",
              inline_format: true
            )
            display_etats_checkboxes
          end
        end

        def display_question_etat_objet
          grid([8, 1], [8, 8]).bounding_box do
            text(
              "<b>Comment évaluez-vous l'état sanitaire de l'objet ?</b>",
              inline_format: true
            )
            display_etats_checkboxes
          end
        end

        def display_question_securisation
          grid([9, 1], [9, 8]).bounding_box do
            text(
              "<b>L'objet est-il en sécurité ?</b>",
              inline_format: true
            )
            checkbox("Oui, il est difficile de le voler")
            move_down CHECKBOX_HEIGHT + GAP
            checkbox("Non, il peut être emporté facilement")
          end
        end

        def display_etats_checkboxes
          y = cursor
          %w[Bon Moyen Mauvais Péril].each_with_index do |label, idx|
            checkbox(label, at: [(@grid.column_width + @grid.gutter) * (idx * 2), y])
          end
        end

        def checkbox(label, at: nil)
          at ||= [0, cursor]
          stroke_rounded_rectangle(at, CHECKBOX_WIDTH, CHECKBOX_HEIGHT, 3)
          text_box(label, at: [at[0] + CHECKBOX_WIDTH + GAP, at[1]], height: CHECKBOX_HEIGHT, valign: :center)
        end
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize
