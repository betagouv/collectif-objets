class LinkDraftRecensementsWithDossier < ActiveRecord::Migration[7.1]
  # Les recensements en brouillon doivent désormais être associés à un dossier, que l'on crée s'il n'existe pas
  def up
    Recensement.draft.where(dossier: nil).find_each do |recensement|
      commune = recensement.objet.commune
      commune.start! if commune.inactive?
      recensement.update(dossier: commune.dossier)
    end
  end
end
