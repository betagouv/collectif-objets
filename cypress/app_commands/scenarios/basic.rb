# frozen_string_literal: true

FactoryBot.create(
  :conservateur, email: "jeanne@culture.gouv.fr", departements: ["26"]
)
commune = FactoryBot.create(
  :commune, nom: "Albon", code_insee: "26002", departement: "26",
            status: Commune::STATE_COMPLETED
)
dossier = FactoryBot.create(:dossier, :submitted, commune:)
user = FactoryBot.create(:user, email: "mairie-albon@test.fr", role: "mairie", commune:)
objet_bouquet = FactoryBot.create(
  :objet, palissy_DENO: "Bouquet d'Autel", palissy_EDIF: "Eglise st Jean",
          commune:
)
FactoryBot.create(
  :recensement,
  objet: objet_bouquet, user:, dossier:,
  etat_sanitaire: Recensement::ETAT_BON,
  etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
  securisation: Recensement::SECURISATION_CORRECTE,
  notes: "objet très doux"
)
objet_ciboire = FactoryBot.create(:objet, palissy_DENO: "Ciboire des malades", palissy_EDIF: "Musée", commune:)
FactoryBot.create(
  :recensement,
  objet: objet_ciboire, user:, dossier:,
  etat_sanitaire: Recensement::ETAT_BON,
  etat_sanitaire_edifice: Recensement::ETAT_MOYEN,
  securisation: Recensement::SECURISATION_CORRECTE,
  notes: nil
)
