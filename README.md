# Collectif Objets

## Generate models

rails g model Objet \
  ref_pop:string \
  ref_memoire:string \
  nom:string \
  categorie:string \
  commune:string \
  commune_code_insee:string \
  departement:string \
  crafted_at:string \
  last_recolement_at:datetime \
  nom_dossier:string \
  edifice_nom:string \
  emplacement:string \
  recolement_status:string
  <!-- materiaux: -->
