# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/MethodLength

module Co
  module Pdf
    module Rapport
      class RecensementPrawn
        BADGES_COLORS = {
          success: %w[b8fec9 18753c],
          error: %w[ffe9e9 ce0500],
          info: %w[e8edff 0063cb],
          warning: %w[ffe9e6 b34000],
          new: %w[feebd0 695240]
        }.freeze

        def initialize(recensement, prawn_doc)
          @recensement = recensement
          @prawn_doc = prawn_doc
        end

        def display
          grid([0, 0], [0, 1]).bounding_box { header }

          photos_grid if recensement.photos.any?

          column_box([0, cursor], columns: 2, width: bounds.width, reflow_margins: true) do
            attributes
          end
        end

        protected

        attr_reader :prawn_doc, :recensement

        delegate(
          :text, :grid, :column_box, :image, :move_down, :start_new_page, :bounds, :cursor, :table,
          :make_table, :bounding_box,
          to: :prawn_doc
        )
        delegate :objet, :photos, to: :recensement

        def presenter
          @presenter ||= RecensementPresenterPdf.new(recensement, prawn_doc)
        end

        def header
          text "<b><u>#{objet.nom}</b></u>", inline_format: true, size: 18
          text ""
          text(
            "objet #{objet.palissy_REF} · " \
            "recensé le #{I18n.l(recensement.updated_at.to_date)} · " \
            "<link href=\"https://www.pop.culture.gouv.fr/notice/palissy/#{objet.palissy_REF}\">" \
            "<u>Voir sur POP →</u></link>",
            inline_format: true
          )
          header_photos_title
        end

        def header_photos_title
          if photos.any?
            move_down 20
            text "<b>#{I18n.t('recensement.photos.taken_count', count: photos.count)}</b>",
                 inline_format: true
          elsif @recensement.missing_photos?
            move_down 5
            display_presentable(**presenter.missing_photos_badge)
            move_down 15
          end
        end

        def attribute(name)
          text "<b>#{I18n.t("dossier.rapport.recensement.#{name}")}</b>", inline_format: true
          display_presentable(**presenter.send(name))
          move_down 20
        end

        def attribute_overridable(name_original)
          text "<b>#{I18n.t("dossier.rapport.recensement.#{name_original}")}</b>", inline_format: true
          name_analyse = "analyse_#{name_original}"
          value_analyse = recensement.send(name_analyse)
          presentable_original = presenter.send(name_original)
          if value_analyse
            presentable_analyse = presenter.send(name_analyse)
            presentable_original[:content] = "<strikethrough>#{presentable_original[:content]}</strikethrough>"
            badges = [presentable_original, presentable_analyse].map { make_badge(**_1) }
            table([badges], cell_style: { borders: [], padding: [0, 5, 0, 5] })
          else
            display_badge(**presentable_original)
          end
          move_down 20
        end

        def attributes
          attribute(:localisation)
          attribute(:recensable)
          return unless recensement.recensable?

          %i[etat_sanitaire_edifice etat_sanitaire securisation].each { attribute_overridable(_1) }
          %i[notes analyse_notes].each { attribute(_1) }
          display_analyse_fiches
        end

        def photos_grid
          [[1, 0], [1, 1], [2, 0], [2, 1], [3, 0], [3, 1], [4, 0], [4, 1], [5, 0],
           [5, 1]].each_with_index do |cell_pos, index|
            break if photos.count <= index

            grid(*cell_pos).bounding_box { display_photo(photos[index]) }
          end
          photos.count > 4 ? start_new_page : move_down(30)
        end

        def display_photo(photo)
          image(
            StringIO.open(photo.variant(:medium).processed.download),
            fit: [bounds.width, bounds.height],
            position: :center
          )
        end

        def display_analyse_fiches
          text "<b>#{I18n.t('dossier.rapport.recensement.analyse_fiches')}</b>", inline_format: true
          recensement.analyse_fiches.each do |fiche|
            fiche_url = "https://collectif-objets.beta.gouv.fr/fiche?pdf=fiche_#{fiche}"
            text "· <u><link href='#{fiche_url}'>voir la fiche #{fiche}</link></u>", inline_format: true
          end
          move_down 20
        end

        def display_presentable(type:, content:, **options)
          case type
          when "badge"
            display_badge(content:, badge_type: options[:badge_type])
          when "text"
            text(content, inline_format: true)
          end
        end

        def make_badge(content:, badge_type:, **_other)
          background_color, text_color = BADGES_COLORS[badge_type.to_sym]
          make_table(
            [[content]],
            cell_style: { background_color:, text_color:, borders: [], padding: [2, 2, 2, 2], inline_format: true }
          )
        end

        def display_badge(content:, badge_type:, **_other)
          make_badge(content:, badge_type:).draw
        end
      end
    end
  end
end

# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/MethodLength
