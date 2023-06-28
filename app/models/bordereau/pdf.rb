# frozen_string_literal: true

module Bordereau
  class Pdf
    include Prawn::View # Permet d'utiliser directement les méthodes de Prawn::Document
    attr_reader :dossier, :edifice

    delegate :commune, to: :dossier

    def initialize(dossier, edifice)
      @dossier = dossier
      @edifice = edifice
    end

    # Utilisé comme référence par Prawn::View
    def document
      @document ||= Prawn::Document.new page_layout: :landscape, page_size: "A4"
    end

    def build_prawn_doc
      setup_fonts
      define_grid(columns: 5, rows: 8, gutter: 0)

      # Partie en haut à gauche avec les logos
      grid([0, 0], [2, 0]).bounding_box do
        image Rails.root.join("prawn_assets/logo-ministere-culture.png"), width: 100
        move_down 20
        image Rails.root.join("prawn_assets/logo-monument-historique.png"), width: 100
      end

      # Partie en haut et centrée avec les titres
      grid([0, 1], [2, 3]).bounding_box do
        text "Direction régionale des affaires culturelles", align: :center, style: :bold
        move_down 10
        text "Conservation des antiquités et objets d’art", align: :center, style: :bold
        move_down 10
        text "Département : #{dossier.departement}", align: :center
        move_down 5
        text "Commune de : #{dossier.commune.nom}", align: :center
        move_down 20
      end

      grid([2, 1], [2, 3]).bounding_box do
        text "Récolement des objets classés de l'édifice #{edifice.nom}", align: :center, style: :bold
      end

      # Notes de bas de page
      grid([7, 0], [7, 4]).bounding_box do
        text <<~TEXT, size: 8
          1    Estimation transmise par la commune au moment du recensement communal « Collectif Objets », éventuellement corrigée par le CAOA au vue des photographies
          2    Expertise du CAOA à la suite du recensement communal
          3    Observations effectuées sur place lors du récolement
        TEXT
      end

      # Page de la liste des objets classés
      recensements_objets_classés = recensements_des_objets_de_l_edifice_typés("classés")
      ajout_table_objets_recensés(recensements_objets_classés) if recensements_objets_classés.present?

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

      # Partie avec les signataires et destinataires
      grid([6, 0], [6, 4]).bounding_box do
        text "Diffusion du bordereau :", style: :bold, size: 10
        text <<~TEXT, size: 8
          Signataires du présent bordereau,
          Préfecture du département, conservation des antiquités et objets d'art
          Direction régionaledes affaires culturelles - conservation régionaledes monuments historiques
          Direction générale des patrimoines et de l’architecture – Bureau de la conservation des monuments historiques mobiliers – Médiathèque du patrimoine et de la photographie
        TEXT
      end

      # Légendes, notes de bas de page
      grid([7, 0], [7, 4]).bounding_box do
        move_down 20
        text <<~TEXT, size: 8
          4    Le cas échéant, indiquer les autres personnes présentes participant au récolement.
          5    Le propriétaire peut être une personne publique ou privée. Préciser, s’il y a lieu, l’affectataire domanial.
          6    Pour les biens affectés au culte au sens de la loi du 9 décembre 1905 concernant la séparation des Églises et de l’État.
        TEXT
      end
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
      lignes = recencements.map { RecensementRow.new(_1).to_a }
      lignes.prepend([
                       "<b>Référence Palissy</b>",
                       "<b>Dénomination</b>",
                       "<b>Date de protection</b>",
                       "<b>Etat de conservation¹</b>",
                       "<b>Observations du conservateur²</b>",
                       "<b>Observations sur le terrain³</b>",
                       "<b>Photographie</b>"
                     ])
      table(lignes, column_widths: [75, 122, 122, 122, 122, 122, 75],
                    cell_style: { size: 8, border_color: "CCCCCC", inline_format: true },
                    header: true)
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

    def ellipsis
      @ellipsis ||= "." * 30
    end
  end
end
