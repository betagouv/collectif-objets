# frozen_string_literal: true

class AddPremiereVisiteToRecenseurs < ActiveRecord::Migration[7.1]
  def change
    add_column :recenseurs, :premiere_visite, :boolean, null: false, default: true
  end
end
