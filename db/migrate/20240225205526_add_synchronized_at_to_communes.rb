class AddSynchronizedAtToCommunes < ActiveRecord::Migration[7.1]
  def change
    add_column :communes, :synchronized_at, :datetime
  end
end
