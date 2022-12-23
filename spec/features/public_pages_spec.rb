# frozen_string_literal: true

require "rails_helper"

feature "public pages accessibility", js: true do
  [
    # ["Liste des objets protégés de toute la France", objets_path],
    # ["Objet #{objet}", objet_path(objet)],
    # ["Liste des communes par département", departements_path],
    # ["Liste des communes du #{departement}", departement_path(departement)],
    # ["Liste des objets de #{commune}", objets_path(commune_code_insee: commune.code_insee)],
    ["Connexion", :connexion_path],
    ["Connexion Communes", :new_user_session_path],
    ["Connexion Conservateur", :new_conservateur_session_path],
    ["Connexion Administrateur", :new_admin_user_session_path],
    # ["Statistiques", :stats_path],
    ["Ils parlent de nous", :presse_path],
    ["Conditions générales d'utilisation", :conditions_path],
    ["Mentions Légales", :mentions_legales_path],
    ["Confidentialité", :confidentialite_path],
    ["Comment ça marche ?", :aide_path],
    ["Guide du recensement", :guide_path]
  ].each do |page_name, path_name|
    scenario "la page publique '#{page_name}' est accessible" do
      visit send(path_name)
      expect(page).to be_axe_clean
    end
  end
end
