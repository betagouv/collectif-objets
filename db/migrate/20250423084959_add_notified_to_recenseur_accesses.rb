class AddNotifiedToRecenseurAccesses < ActiveRecord::Migration[7.1]
  def change
    add_column :recenseur_accesses, :notified, :boolean, null: false, default: false
  end
end
