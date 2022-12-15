class AddCustomMessageToCampaigns < ActiveRecord::Migration[7.0]
  def up
    add_column :campaigns, :custom_message, :text
    Campaign
      .where(departement_code: "55") # Meuse
      .update_all(custom_message:
        <<-TEXT
          Le recensement porte uniquement sur les biens appartenant à la commune. Il ne concerne pas les éventuels biens déposés au Musée d’Art sacré de Saint-Mihiel ou à la Cathédrale de Verdun. Pour ces objets, il vous suffira de répondre à la question « Où se trouve l’objet ? » que les objets ont été déposés.
        TEXT
      )
    Campaign
      .where(departement_code: "57") # Moselle
      .update_all(custom_message:
        <<-TEXT
          Le recensement porte uniquement sur les biens appartenant à la commune. Pour les objets conservés dans l’église communale, il convient de prendre l’attache du Conseil de Fabrique afin d’effectuer conjointement ce recensement.
        TEXT
      )
  end

  def down
    remove_column :campaigns, :custom_message
  end
end
