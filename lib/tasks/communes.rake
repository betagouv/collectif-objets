require 'csv'

namespace :communes do
  desc "creates communes from objets"
  task :create, [:path] => :environment do |_, args|
    Commune.delete_all
    for row in Objet.select("DISTINCT ON(commune_code_insee) commune, commune_code_insee, departement").to_a do
      Commune.create!(
        nom: row.commune.nom,
        code_insee: row.commune_code_insee,
        departement: row.departement
      )
    end
  end

  desc "export communes"
  task :export, [:path] => :environment do |_, args|
    headers = [
      "nom",
      "code_insee",
      "departement",
      "email",
      "phone_number",
      "population",
      "nombre_objets",
      "main_objet_img_url",
      "main_objet_nom",
      "main_objet_edifice",
      "main_objet_emplacement",
    ]
    CSV.open(args[:path], "wb", headers: true) do |csv|
      csv << headers
      Commune.includes(:objets).find_each do |commune|
        csv << [
          commune.nom,
          commune.code_insee,
          commune.departement,
          commune.email,
          commune.phone_number,
          commune.population,
          commune.objets.count,
          commune.main_objet&.image_urls&.first,
          commune.main_objet&.nom,
          commune.main_objet&.edifice_nom,
          commune.main_objet&.emplacement
        ]
      end
    end
  end

end
