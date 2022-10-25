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

  # rake "communes:fix_noms[../collectif-objets-data/mairies.from_service_public.csv]"
  task :strip_noms do
    Commune.all.to_a.each do |commune|
      next if commune.nom.strip == commune.nom

      puts "stripping commune nom '#{commune.nom}'"
      commune.update!(nom: commune.nom.strip)
    end; nil
  end
end
