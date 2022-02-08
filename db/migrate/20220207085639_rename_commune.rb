# frozen_string_literal: true

class RenameCommune < ActiveRecord::Migration[7.0]
  def change
    rename_column :objets, :commune, :commune_nom
  end
end
