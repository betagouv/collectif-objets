# frozen_string_literal: true

require "csv"

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

  # rake "communes:export[../../collectif-objets-data/rails-communes.csv]"
  desc "export communes"
  task :export, [:path] => :environment do |_, args|
    headers = [
      "nom",
      "code_insee",
      "departement",
      "email",
      "magic_token",
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
      communes = Commune.includes(:objets).to_a.sort_by { _1.objets.count }.reverse
      communes.each do |commune|
        csv << [
          commune.nom,
          commune.code_insee,
          commune.departement,
          commune.email,
          commune.users.first&.magic_token,
          commune.phone_number,
          commune.population,
          commune.objets.count,
          commune.main_objet&.image_urls&.first,
          commune.main_objet&.nom_formatted,
          commune.main_objet&.edifice_nom_formatted,
          commune.main_objet&.emplacement
        ]
      end
    end
  end

  # rake "communes:fix_noms[../collectif-objets-data/mairies.from_service_public.csv]"
  task :fix_noms, [:path] => :environment do |_, args|
    puts "code_insee\tnom_db_formatted\tnom_insee"
    communes_by_code_insee = Commune.all.map { [_1.code_insee, _1] }.to_h
    for row in CSV.read(args[:path], headers: true) do
      next if row["TYPECOM"] != "COM"

      commune = communes_by_code_insee[row["COM"].to_s.rjust(5, "0")]
      nom_insee = row["LIBELLE"]
      next if commune.nil? || commune.nom == nom_insee

      nom_db = commune.nom || ""
      match_data = nom_db.match(/(.*) ?\((.*)\)/)
      if match_data
        _, nom, prefixe = match_data.to_a
        nom_db = "#{prefixe} #{nom}".strip
      end
      # next if nom_db == nom_insee || nom_db.parameterize == nom_insee.parameterize

      puts "#{commune.code_insee}\t#{commune.nom}\t#{nom_insee}"
      commune.update!(nom: nom_insee)
    end
  end

end
