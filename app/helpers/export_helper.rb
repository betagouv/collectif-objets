# frozen_string_literal: true

module ExportHelper
  MEMOIRE_EXPORT_COLS = [
    { nom: "LBASE", desc: "Identifiant de l’objet photographié", desc2: "ex: PM3049585" },
    { nom: "REF", desc: "Référence qui sera indiquée sur la notice Mémoire", desc2: "MHCO + NUMP" },
    { nom: "REFIMG", desc: "Référence du fichier numérique avec cote", desc2: "« . » format" },
    { nom: "NUMP", desc: "Numéro du phototype", desc2: "AAAA + numéro de département + numéro d’ordre de la photo" },
    { nom: "DATPV", desc: "Date de prise de vue", desc2: "AAAA" },
    { nom: "COULEUR", desc: "Photographie en couleur", fixed: true, desc2: "Oui / Non" },
    { nom: "OBS", desc: "doute sur la localisation, sur le nom du photographe, fonction du photographe…", fixed: true,
      desc2: "" },
    { nom: "COM", desc: "Commune sous sa forme éditorialisée", desc2: "ex: Vouziers" },
    { nom: "DOM", desc: "Domaine : Objet ou Architecture", fixed: true, desc2: "objet" },
    { nom: "EDIF",
      desc: "Nom de l’édifice où se trouve l’objet. SI édifice protégé, reprendre l’appellation de Mérimée MH",
      desc2: "" },
    { nom: "COPY", desc: "Crédits", fixed: true, desc2: "© Ministère de la Culture…" },
    { nom: "TYPDOC", desc: "Type de documents", fixed: true, desc2: "Image numérique native" },
    { nom: "IDPROD", desc: "", fixed: true, desc2: "MHCO008" },
    { nom: "LIEUCOR", desc: "", fixed: true, desc2: "Collectif Objets" }
  ].freeze

  def memoire_export_columns = MEMOIRE_EXPORT_COLS
end
