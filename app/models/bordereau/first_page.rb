# frozen_string_literal: true

module Bordereau
  class FirstPage < Page
    def render
      define_grid(columns: 5, rows: 8, gutter: 0)
      grid([0, 0], [2, 0]).bounding_box { render_upper_left }
      grid([0, 1], [2, 3]).bounding_box { render_upper_center }
      grid([0, 4], [2, 4]).bounding_box { render_upper_right }
      grid(3, 0).bounding_box { text "Diffusion du bordereau :", style: :bold }
      grid([3, 1], [3, 3]).bounding_box { render_intermediate_row_center }
      grid([4, 0], [5, 4]).bounding_box { render_table }
      grid([7, 0], [7, 4]).bounding_box { render_footnotes }
    end

    private

    def render_upper_left
      image Rails.root.join("prawn_assets/logo-ministere-culture.png"), width: 100
      move_down 20
      image Rails.root.join("prawn_assets/logo-monument-historique.png"), width: 100
    end

    def render_upper_center
      text "Direction régionale des affaires culturelles de Grand Est", align: :center, style: :bold
      move_down 10
      text "CONSERVATION DES ANTIQUITÉS ET OBJETS D'ART", align: :center, style: :bold
      move_down 30
      stroke_horizontal_rule
      move_down 50
      text "RÉCOLEMENT", align: :center, style: :bold, size: 20
      text "des objets mobiliers, soit meubles proprement dits, soit immeubles par destination, \n" \
           "classés au titre des monuments historiques dans l’immeuble de localisation désigné ci-contre",
           align: :center, style: :bold, size: 8
      text "En application des articles L 622-8 et R 622-25 du Code du Patrimoine",
           align: :center, style: :italic, size: 8
    end

    def render_upper_right
      text "<b>DÉPARTEMENT</b> : #{dossier.departement}", inline_format: true
      move_down 10
      text "<b>COMMUNE</b>: #{dossier.commune.nom}", inline_format: true
      move_down 10
      text "<b>Code INSEE</b>: #{dossier.commune.code_insee}", inline_format: true
      move_down 10
      text "<b>Immeuble de localisation</b> :", inline_format: true
      text edifice.nom
      move_down 10
      text "<b>Adresse :</b>", inline_format: true
    end

    def render_intermediate_row_center
      text <<~TEXT, size: 8
        Signataires du présent bordereau,
        Préfecture du département, conservation des antiquités et objets d'art
        Direction régionaledes affaires culturelles - conservation régionaledes monuments historiques
        Direction générale des patrimoines et de l’architecture – Bureau de la conservation des monuments historiques mobiliers – Médiathèque du patrimoine et de la photographie
      TEXT
    end

    def render_table
      table \
        [
          [
            "<b>Référence Palissy</b>",
            "<b>Dénomination</b>",
            "<b>Date de Classement</b>",
            "<b>Etat de conservation¹</b>",
            "<b>Observations du conservateur²</b>",
            "<b>Observations sur le terrain³</b>",
            "<b>Photographie</b>"
          ]
        ],
        column_widths: COLUMN_WIDTHS,
        cell_style: { inline_format: true, size: 8, border_color: "CCCCCC" }
    end

    def render_footnotes
      text <<~TEXT, size: 8
        1    Estimation transmise par la commune au moment du recensement communal « Collectif Objets », éventuellement corrigée par le CAOA au vue des photographies
        2    Expertise du CAOA à la suite du recensement communal
        3    Observations effectuées sur place lors du récolement
      TEXT
    end
  end
end
