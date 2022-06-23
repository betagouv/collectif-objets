class AasmTimestampsOnCommunes < ActiveRecord::Migration[7.0]
  def up
    add_column :communes, :started_at, :datetime

    Commune.joins(:recensements).includes(:recensements).each do |commune|
      started_at = commune.recensements.map(&:created_at).min
      puts "setting started_at on commune #{commune.code_insee} with #{started_at}"
      commune.update!(started_at:)
    end
  end

  def down
    remove_column :communes, :started_at
  end
end
