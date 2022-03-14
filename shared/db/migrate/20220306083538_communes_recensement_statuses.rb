class CommunesRecensementStatuses < ActiveRecord::Migration[7.0]
  def change
    add_column :communes, :status, :string
    add_column :communes, :notes_from_enrollment, :string
    add_column :communes, :notes_from_completion, :string
    add_column :communes, :enrolled_at, :datetime
    add_column :communes, :completed_at, :datetime
    add_column :users, :nom, :string
    add_column :users, :job_title, :string
    add_column :users, :email_personal, :string
    add_column :users, :phone_number, :string
    remove_column :objets, :recolement_status, :string
  end
end
