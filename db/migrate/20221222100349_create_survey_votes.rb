class CreateSurveyVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :survey_votes do |t|
      t.references :commune
      t.string :survey
      t.string :reason
      t.string :additional_info

      t.timestamps
    end
    add_index :survey_votes, [:commune_id, :survey], unique: true
  end
end
