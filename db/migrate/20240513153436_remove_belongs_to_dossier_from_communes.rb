class RemoveBelongsToDossierFromCommunes < ActiveRecord::Migration[7.1]
  def change
    remove_belongs_to :communes, :dossier, index: true
  end
end
