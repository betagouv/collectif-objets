# frozen_string_literal: true

module Bordereau
  COLUMN_WIDTHS = [75, 122, 122, 122, 122, 122, 75].freeze
  CELL_STYLE = { size: 8, border_color: "CCCCCC" }.freeze

  class Pdf
    include Prawn::View
    attr_reader :dossier, :edifice

    delegate :commune, to: :dossier

    def initialize(dossier, edifice)
      @dossier = dossier
      @edifice = edifice
    end

    def document
      @document ||= Prawn::Document.new page_layout: :landscape, page_size: "A4"
    end

    def build_prawn_doc
      setup_fonts
      FirstPage.new(self).render

      # Page de la liste des objets classés
      recensements_objets_classés = recensements_des_objets_de_l_edifice_typés("classés")
      if recensements_objets_classés.present?
        start_new_page
        ajout_table_objets_recensés(recensements_objets_classés)
      end

      # Page de la liste des objets inscrits
      recensements_objets_inscrits = recensements_des_objets_de_l_edifice_typés("inscrits")
      if recensements_objets_inscrits.present?
        start_new_page
        text "LISTE DES OBJETS INSCRITS", align: :center, style: :bold, size: 16
        text "Toutes les informations liées à ces objets figurent dans Collectif Objets " \
             "et dans le rapport transmis par vos CMH et CAOA",
             align: :center, size: 10
        move_down(10)
        ajout_table_objets_recensés(recensements_objets_inscrits)
      end

      # Page de signature
      start_new_page
      LastPage.new(self).render
      document
    end

    private

    # TODO: À refacto dans un modèle (Recensement ou Objet)
    def recensements_des_objets_de_l_edifice_typés(niveau_de_protection)
      @dossier
        .recensements
        .joins(:objet)
        .where(objets: { edifice_id: edifice.id })
        .merge(niveau_de_protection == "classés" ? Objet.classés : Objet.inscrits)
        .order('objets."palissy_REF"')
    end

    def ajout_table_objets_recensés(recencements)
      table \
        recencements.map { RecensementRow.new(_1).to_a },
        column_widths: COLUMN_WIDTHS,
        cell_style: CELL_STYLE
    end

    def setup_fonts
      font_families.update \
        "Marianne" => {
          normal: Rails.root.join("prawn_assets/Marianne-Regular.ttf"),
          italic: Rails.root.join("prawn_assets/Marianne-RegularItalic.ttf"),
          bold: Rails.root.join("prawn_assets/Marianne-Bold.ttf")
        }
      font "Marianne"
    end
  end
end
