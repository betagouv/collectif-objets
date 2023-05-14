# frozen_string_literal: true

module Bordereau
  COLUMN_WIDTHS = [75, 122, 122, 122, 122, 122, 75].freeze

  class Pdf
    attr_reader :prawn_doc, :dossier, :edifice

    delegate :commune, to: :dossier

    def initialize(dossier, edifice)
      @dossier = dossier
      @edifice = edifice
    end

    def build_prawn_doc
      @prawn_doc = Prawn::Document.new page_layout: :landscape, page_size: "A4"
      setup_fonts
      FirstPage.new(self).render
      prawn_doc.start_new_page
      prawn_doc.table \
        recensements_rows,
        column_widths: COLUMN_WIDTHS,
        cell_style: { size: 8, border_color: "CCCCCC" }
      prawn_doc.start_new_page
      LastPage.new(self).render
      prawn_doc
    end

    private

    def recensements_rows
      @recensements_rows ||= recensements.map { RecensementRow.new(_1).to_a }
    end

    def recensements
      @recensements ||= @dossier
        .recensements
        .joins(:objet)
        .where(objets: { edifice_id: edifice.id })
        .merge(Objet.classés)
        .order('objets."palissy_REF"')
    end

    def setup_fonts
      prawn_doc.font_families.update \
        "Marianne" => {
          normal: Rails.root.join("prawn_assets/Marianne-Regular.ttf"),
          italic: Rails.root.join("prawn_assets/Marianne-RegularItalic.ttf"),
          bold: Rails.root.join("prawn_assets/Marianne-Bold.ttf")
        }
      prawn_doc.font "Marianne"
    end
  end
end
