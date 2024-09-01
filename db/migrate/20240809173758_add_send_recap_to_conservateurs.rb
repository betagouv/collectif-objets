class AddSendRecapToConservateurs < ActiveRecord::Migration[7.1]
  def change
    add_column :conservateurs, :send_recap, :boolean, null: false, default: true
  end
end
