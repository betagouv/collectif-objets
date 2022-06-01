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

  # rake "communes:import_statuses[../../collectif-objets-data/airtable-communes-statuses.csv]"
  task :import_statuses, [:path] => :environment do |_, args|
    for row in CSV.read(args[:path], headers: true) do
      commune = Commune.find_by_code_insee(row["code_insee"])
      if commune.nil?
        puts "⚠️ no commune found for #{row["code_insee"]} : #{row["nom"]}"
        next
      end

      if row["user_nom"].present?
        user = commune.users.first
        raise "no user found for #{row["code_insee"]}" if user.nil?
      end

      updates = row.to_h.slice("enrolled_at", "notes_from_enrollment").compact
      if commune.inactive? ||
        (commune.enrolled? && ["started", "completed"].include?(row["status"])) ||
        (commune.started? && row["status"] == "completed")
        updates["status"] = row["status"]
      end
      puts "updating #{row["code_insee"]} with #{updates}"
      commune.update!(updates)

      if row["user_nom"].present?
        user = commune.users.first
        updates = {
          "job_title": row["user_job_title"],
          "nom": row["user_nom"],
          "email_personal": row["user_email_personal"],
          "phone_number": row["user_phone_number"],
        }.compact
        puts "updating #{user["email"]} with #{updates}"
        user.update!(updates)
      end
    end
  end

end
