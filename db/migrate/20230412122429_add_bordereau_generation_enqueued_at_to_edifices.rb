class AddBordereauGenerationEnqueuedAtToEdifices < ActiveRecord::Migration[7.0]
  def change
    add_column :edifices, :bordereau_generation_enqueued_at, :datetime
  end
end
