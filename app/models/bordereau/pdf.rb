# frozen_string_literal: true

module Bordereau
  class Pdf
    include Prawn::View # Permet d'utiliser directement les méthodes de Prawn::Document
    attr_reader :dossier, :edifice

    delegate :commune, to: :dossier

    def initialize(dossier, edifice)
      @dossier = dossier
      @edifice = edifice
      build_prawn_doc
    end

    # Utilisé comme référence par Prawn::View
    def document
      @document ||= Prawn::Document.new page_layout: :landscape, page_size: "A4"
    end

    def to_io
      StringIO.new(document.render)
    end

    def filename
      "bordereau-#{dossier.commune.to_s.parameterize}-#{edifice.nom.parameterize}.pdf"
    end

    private

    def build_prawn_doc
      setup_fonts
      define_grid(columns: 5, rows: 8, gutter: 0)

      add_logos
      add_header

      recensements_objets_classés = recensements_des_objets_de_l_edifice_typés("classés")
      if recensements_objets_classés.present?
        ajout_table_objets_recensés(recensements_objets_classés)
        add_signatures
        add_footnotes
      end

      # Page de la liste des objets inscrits
      recensements_objets_inscrits = recensements_des_objets_de_l_edifice_typés("inscrits")
      if recensements_objets_inscrits.present?
        start_new_page if recensements_objets_classés.present?

        text "Liste des objets inscrits de l'édifice #{edifice.nom}", align: :center, style: :bold, size: 12
        text "Toutes les informations liées à ces objets figurent dans Collectif Objets " \
             "et dans l'examen transmis par vos CMH et CAOA",
             align: :center, size: 10
        move_down(10)
        ajout_table_objets_recensés(recensements_objets_inscrits)
      end

      add_legalese

      # Les pages générées après `number_pages` ne sont pas numérotées
      number_pages "<page>/<total>", at: [bounds.right - 150, 0], align: :right

      document
    end

    def add_logos
      grid([0, 0], [1, 0]).bounding_box do
        image Rails.root.join("prawn_assets/logo-ministere-culture.png"), width: 100
        move_down 20
        image Rails.root.join("prawn_assets/logo-monument-historique.png"), width: 100
      end
    end

    def add_header
      grid([0, 1], [1, 3]).bounding_box do
        text "Direction régionale des affaires culturelles", align: :center, style: :bold, size: 10
        move_down 2
        text "Conservation des antiquités et objets d’art".upcase, align: :center, style: :bold, size: 10
        stroke_horizontal_rule
        move_down 10
        text "Bordereau de récolement des objets mobilier".upcase, align: :center, style: :bold, size: 14
        move_down 10
        text "Département : #{dossier.departement}", align: :center
        move_down 5
        text "Commune de : #{dossier.commune.nom}", align: :center
        move_down 5
        text "Édifice : #{edifice.nom.upcase_first}", align: :center
        # TODO: Ajouter l'adresse récupérée lors de l'import depuis Palissy
      end
    end

    def add_signatures
      start_new_page
      define_grid(columns: 5, rows: 8, gutter: 0)
      text "Participants au récolement¹ :", style: :bold
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
            "<i>Le propriétaire² ou son représentant,</i>",
            "<i>L’affectataire³,</i>",
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
          Direction régionale des affaires culturelles - conservation régionale des monuments historiques
          Direction générale des patrimoines et de l’architecture – Bureau de la conservation des monuments historiques mobiliers – Médiathèque du patrimoine et de la photographie
        TEXT
      end
    end

    def add_footnotes
      grid([7, 0], [7, 4]).bounding_box do
        move_down 20
        text <<~TEXT, size: 8
          1    Le cas échéant, indiquer les autres personnes présentes participant au récolement.
          2    Le propriétaire peut être une personne publique ou privée. Préciser, s’il y a lieu, l’affectataire domanial.
          3    Pour les biens affectés au culte au sens de la loi du 9 décembre 1905 concernant la séparation des Églises et de l’État.
        TEXT
      end
    end

    def add_legalese
      start_new_page # On remplit une page entière en taille 10
      text <<~TEXT, inline_format: true, size: 10
        <b>Références législatives et réglementaires dans le code du patrimoine</b>

        <b>Article L.622-8</b>
        Il est procédé, par l'autorité administrative, au moins tous les cinq ans, au récolement des objets mobiliers classés au titre des monuments historiques.
        En outre, les propriétaires ou détenteurs de ces objets sont tenus, lorsqu'ils en sont requis, de les présenter aux agents accrédités par l'autorité administrative.

        <b>Article R.622-9</b>
        La liste générale des objets mobiliers et des ensembles historiques mobiliers classés, établie et publiée par le ministère chargé de la culture, comprend :
        1° La dénomination ou la désignation et les principales caractéristiques de ces objets et ensembles historiques mobiliers ;
        2° L'indication de l'immeuble et de la commune où ils sont conservés, et, le cas échéant, de la servitude de maintien dans les lieux attachés à l'objet mobilier ou à l'ensemble historique mobilier concerné. Toutefois, si l'objet mobilier ou l'ensemble historique mobilier appartient à un propriétaire privé, celui-ci peut demander que seule l'indication du département soit mentionnée ;
        3° La qualité de personne publique ou privée de leur propriétaire et, s'il y a lieu, l'affectataire domanial ;
        4° La date de la décision de classement.

        <b>Article R.622-24</b>
        La présentation des objets mobiliers classés, faite à la demande des services de l’État chargés des monuments historiques en application du deuxième alinéa de l'article L.622-8, s'effectue sur leur lieu habituel de conservation. Toutefois, les propriétaires, affectataires, détenteurs ou dépositaires de ces objets peuvent demander que cette présentation s'effectue dans un autre lieu.
        Le contrôle sur place des biens protégés s'effectue en présence du propriétaire, de l'affectataire ou de leur représentant. En cas d'absence, il s'effectue avec leur accord.

        <b>Article R.622-25</b>
        Le conservateur des antiquités et des objets d'art procède au moins tous les cinq ans au récolement des objets mobiliers classés.
        Le préfet du département accrédite les agents auxquels les propriétaires ou détenteurs de ces objets sont tenus, en application du second alinéa de l'article L.622-8, de les présenter.

        <b>Article R.622-38</b>
        Le préfet de région dresse une liste des objets mobiliers inscrits de la région qui contient les mêmes renseignements que ceux énumérés à l'article R.622-9.
        Un exemplaire de cette liste, tenue à jour, est déposé au ministère chargé de la culture, à la direction régionale des affaires culturelles et auprès du conservateur des antiquités et des objets d'art.
      TEXT
    end

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
                       "<b>Etat de conservation</b>",
                       "<b>Observations</b>",
                       "<b>Photographie</b>"
                     ])
      table(lignes, column_widths: [75, 122, 122, 122, 244, 75],
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
