class DisablePostgis < ActiveRecord::Migration[7.1]
  def change
    disable_extension :postgis
  end
end
