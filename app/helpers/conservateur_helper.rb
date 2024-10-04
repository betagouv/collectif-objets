# frozen_string_literal: true

module ConservateurHelper
  def conservateur_commune_tabs(commune)
    tab = Data.define(:key, :title, :path)
    [
      tab.new(:analyse, "Recensement", conservateurs_commune_path(commune)),
      tab.new(:messagerie, commune_messagerie_title(commune), conservateurs_commune_messages_path(commune)),
      tab.new(:rapport, "Examen", conservateurs_commune_dossier_path(commune)),
      tab.new(:bordereaux, "Bordereaux de récolement", conservateurs_commune_bordereaux_path(commune)),
      if commune.archived_dossiers.any?
        tab.new(:historique, "Historique",
                conservateurs_commune_historique_path(commune))
      end
    ].compact
  end
end
