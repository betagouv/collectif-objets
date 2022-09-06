class RemoveEnrolledFromCommunes < ActiveRecord::Migration[7.0]
  def up
    remove_column :communes, :enrolled_at
    remove_column :communes, :notes_from_enrollment
    Commune.where(status: "enrolled").update_all(status: "inactive")
  end

  def down
    add_column :communes, :enrolled_at, :datetime
    add_column :communes, :notes_from_enrollment, :string
  end
end
