# frozen_string_literal: true

module Bordereau
  class LastPage < Page
    def render
      define_grid(columns: 5, rows: 8, gutter: 0)
      text "Participants au récolement⁴ :", style: :bold
      move_down 20
      text <<~TEXT, inline_format: true
        Les soussignés (<i>nom, prénom en toutes lettres, fonction et signature</i>) certifient que les objets mobiliers ou immeubles par destination portés au present etat figurent dans l’édifice «#{edifice.nom}», #{commune}, lors du récolement en date du #{ellipsis}
      TEXT
      move_down 40
      text "Fait à #{ellipsis}, le #{ellipsis}", align: :right
      move_down 40
      table \
        [
          [
            "<i>Le propriétaire⁵ ou son représentant,</i>",
            "<i>L’affectataire⁶,</i>",
            "<i>Le Conservateur des Antiquités et Objets d’Art,</i>"
          ]
        ],
        column_widths: [256, 256, 256],
        cell_style: { border_color: "FFFFFF", style: :italic, inline_format: true, size: 11 }
      grid([7, 0], [7, 4]).bounding_box do
        text <<~TEXT, size: 8
          4    Le cas échéant, indiquer les autres personnes présentes participant au récolement.
          5    Le propriétaire peut être une personne publique ou privée. Préciser, s’il y a lieu, l’affectataire domanial.
          6    Pour les biens affectés au culte au sens de la loi du 9 décembre 1905 concernant la séparation des Églises et de l’État.
        TEXT
      end
    end

    private

    def ellipsis
      @ellipsis ||= "." * 30
    end
  end
end
