require 'csv'

def optional_filter(list)
  filtered = list.filter { yield _1 }
  filtered.any? ? filtered : list
end


namespace :communes do
  desc "creates communes from objets"
  task :create, [:path] => :environment do |_, args|
    Commune.delete_all
    for row in Objet.select("DISTINCT ON(commune_code_insee) commune, commune_code_insee, departement").to_a do
      Commune.create!(
        nom: row.commune,
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
        objets = commune.objets.with_images.where.not(nom: nil).to_a
        main_objet = nil
        if objets.any?
          main_objet = optional_filter(objets) { !_1.nom.include?(";") }
          main_objet = optional_filter(objets) { !_1.nom.match?(/[A-Z]/) }
          main_objet = optional_filter(objets) { _1.edifice_nom.present? }
          main_objet = optional_filter(objets) { _1.edifice_nom&.match?(/[A-Z]/) }
          main_objet = optional_filter(objets) { !_1.emplacement.present? }
          main_objet = objets.first
        end
        csv << [
          commune.nom,
          commune.code_insee,
          commune.departement,
          commune.email,
          commune.phone_number,
          commune.population,
          commune.objets.count,
          main_objet&.image_urls&.first,
          main_objet&.nom,
          main_objet&.edifice_nom,
          main_objet&.emplacement
        ]
      end
    end
  end

end
