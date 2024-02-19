class AddPalissyDeplWebMosaToObjets < ActiveRecord::Migration[7.1]
  def change
    add_column :objets, "palissy_DEPL", :string
    add_column :objets, "palissy_WEB", :string
    add_column :objets, "palissy_MOSA", :string
    add_column :objets, "lieu_actuel_code_insee", :string
    add_column :objets, "lieu_actuel_edifice_nom", :string
    add_column :objets, "lieu_actuel_edifice_ref", :string

    reversible do |dir|
      dir.up do
        ActiveRecord::Base.connection.execute \
          <<~SQL
            UPDATE objets
            SET
              "lieu_actuel_code_insee" = "palissy_INSEE",
              "lieu_actuel_edifice_nom" = "palissy_EDIF",
              "lieu_actuel_edifice_ref" = "palissy_REFA";
          SQL
      end
    end
  end
end
