# frozen_string_literal: true

module Co
  module Rapports
    class PrawnView
      include Prawn::View

      MARIANNE_FONT = {
        normal: "app/assets/fonts/Marianne-Regular.ttf",
        bold: "app/assets/fonts/Marianne-Bold.ttf",
        italic: "app/assets/fonts/Marianne-Regular_Italic.ttf"
      }.freeze

      def initialize(dossier)
        @dossier = dossier
        font_families.update("Marianne" => MARIANNE_FONT)
        font("Marianne")
        define_grid(columns: 2, rows: 6, gutter: 5)
        display_content
        display_footer
      end

      def display_dossier_notes
        text "<b>Commentaires généraux</b>", inline_format: true, size: 18
        move_down 30
        text "<b>#{I18n.t('activerecord.attributes.dossier.notes_commune')}</b>", inline_format: true
        text(@dossier.notes_commune.presence || "<i>Aucun commentaire</i>", inline_format: true)

        move_down 30
        text "<b>#{I18n.t('activerecord.attributes.dossier.notes_conservateur')}</b>", inline_format: true
        text(@dossier.notes_conservateur.presence || "<i>Aucun commentaire</i>", inline_format: true)
      end

      def display_cover_page
        display_logos
        move_down 10
        text "Rapport de recensement", size: 24, inline_format: true, align: :center
        move_down 100
        text @dossier.commune.nom, size: 24, align: :center
        text "Code INSEE #{@dossier.commune.code_insee}", align: :center
        move_down 100
        text "Dossier de recensement analysé le #{I18n.l(@dossier.pdf_updated_at.to_date)}", align: :center
        text "par #{@dossier.conservateur}", align: :center
      end

      def display_logos
        move_down 50
        image "app/assets/images/logo-ministere-de-la-culture.png", position: :center, width: 150
        move_down 100
        text "<b>Collectif Objets</b>", size: 24, inline_format: true, align: :center
      end

      def display_content
        display_cover_page
        start_new_page
        display_dossier_notes
        start_new_page
        @dossier.recensements.each do |recensement|
          Co::Rapports::RecensementPrawn.new(recensement, self).display
          start_new_page
        end
        display_last_page
      end

      # rubocop:disable Metrics/MethodLength
      def display_last_page
        move_down 100
        text(
          "Fin du dossier de recensement analysé le #{I18n.l(@dossier.pdf_updated_at.to_date)}" \
          " par #{@dossier.conservateur} (#{@dossier.conservateur.email})",
          align: :center
        )
        return unless @dossier.recensements.any?(&:analyse_fiches?)

        move_down 100
        fiches_url = "https://collectif-objets.beta.gouv.fr/fiches"
        text("Vous pouvez retrouver toutes les fiches conseil sur", align: :center)
        text("<u><link href='#{fiches_url}'>#{fiches_url}</link></u>", align: :center, inline_format: true)
      end
      # rubocop:enable Metrics/MethodLength

      def display_footer
        number_pages(
          [
            "Rapport de recensement",
            @dossier.commune.nom,
            I18n.l(@dossier.pdf_updated_at.to_date),
            "p.<page>/<total>"
          ].join(" · "),
          at: [bounds.left, -10], align: :right, start_count_at: 1, size: 10, color: "666666"
        )
      end
    end
  end
end
