class AddRegionToDepartements < ActiveRecord::Migration[7.1]
  def change
    add_column :departements, :region, :string
    up_only do
      say_with_time "Add region name to departements" do
        Departement::REGIONS.each do |name, codes_departement|
          Departement.where(code: codes_departement).update_all(region: name)
        end
        Departement::REGIONS.size
      end
    end
  end
end
