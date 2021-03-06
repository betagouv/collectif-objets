# frozen_string_literal: true

require "csv"

def iterate_files(glob_path)
  Dir.glob(glob_path) do |csv_path|
    puts "reading file #{csv_path}..."
    for row in CSV.read(csv_path, headers: true, col_sep: ";") do
      yield(row.to_h.transform_keys(&:parameterize))
    end
  end
end

namespace :objets do
  # rake objets:import[../tmp-pop-custom-export-filtered-65.csv]
  desc "imports objets from custom export POP CSV"
  task :import, [:path] => :environment do |_, args|
    mapping = {
      memoire_REF: "Référence de l’illustration (Mémoire)",
      palissy_REF: "Référence de la notice Palissy",
      palissy_DENO: "Nom de l'objet",
      palissy_CATE: "CATE",
      palissy_COM: "COM",
      # commune_code_insee:
      palissy_DPT: "DPT",
      palissy_SCLE: "SOUR",
      palissy_DENQ: "DENQ",
      palissy_DOSS: "DOSS",
      palissy_EDIF: "Edifice",
      palissy_EMPL: "Emplacement",
      # recolement_status: "Statut recensement"
    }
    for row in CSV.read(args[:path], headers: true) do
      row_parameterized = row.to_h.transform_keys(&:parameterize)
      cols = row_parameterized.keys
      missing_cols = mapping.values.map(&:parameterize).reject { |col| cols.include?(col) }
      if missing_cols.any?
        raise StandardError.new "missing cols: #{missing_cols}"
      end

      Objet.create!(mapping.transform_values { row_parameterized[_1.parameterize] })
    end
  end

  # rake "objets:import_images[../../pop-scraper/exports/palissy/palissy_dpt_52.csv]"
  task :import_images, [:path] => :environment do |_, args|
    puts "before: #{Objet.with_images.count} objets have photos"
    pop_s3_url = "https://s3.eu-west-3.amazonaws.com/pop-phototeque"
    for row in CSV.read(args[:path], headers: true) do
      next if row["MEMOIRE_URLS"].blank?

      objet = Objet.find_by(palissy_REF: row["REF"])
      next unless objet

      new_image_urls = row["MEMOIRE_URLS"].split(";").map { "#{pop_s3_url}/#{_1}" }
      next if objet.image_urls == new_image_urls

      if objet.image_urls.present?
        puts "updating image urls for #{objet.palissy_REF} : "
        puts "before: "
        objet.image_urls.each { puts(_1) }
        puts "after: "
        new_image_urls.each { puts(_1) }
      else
        puts "adding #{new_image_urls.count} new images for #{objet.palissy_REF}"
      end
      puts

      objet.update!(image_urls: new_image_urls)
    end
    puts "after: #{Objet.with_images.count} objets have photos"
  end

  # rake objets:import_insee[../collectif-objets-data/pop-exports-custom]
  task :import_insee, [:path] => :environment do |_, args|
    puts "before: #{Objet.where.not(commune_code_insee: nil).count}/#{Objet.count} objets have insee code"
    iterate_files("#{args[:path]}/*.csv") do |row|
      next if row["ref"].blank? || row["insee"].blank?

      objet = Objet.find_by(palissy_REF: row["ref"])
      next unless objet

      objet.commune_code_insee = row["insee"]
      objet.save!
    end
    puts "after: #{Objet.where.not(commune_code_insee: nil).count}/#{Objet.count} objets have insee code"
  end

  # rake "objets:import_nom_courant[../collectif-objets-data/pop-exports-custom]"
  task :import_nom_courant, [:path] => :environment do |_, args|
    puts "after: #{Objet.where.not(palissy_TICO: nil).count}/#{Objet.count} objets have nom courant"
    iterate_files("#{args[:path]}/*.csv") do |row|
      next if row["ref"].blank? || row["tico"].blank?

      objet = Objet.find_by(palissy_REF: row["ref"])
      next unless objet

      objet.palissy_TICO = row["tico"]
      objet.save!
    end
    puts "after: #{Objet.where.not(palissy_TICO: nil).count}/#{Objet.count} objets have nom courant"
  end

  # rake "objets:export[../collectif-objets-data/rails-objets-wrong-images.csv]"
  desc "export wrong images"
  task :export_wrong_images, [:path] => :environment do |_, args|
    headers = ["ref", "image_urls"]
    CSV.open(args[:path], "wb", headers: true) do |csv|
      csv << headers
      objets = Objets.
      objets.each do |objet|
        csv << [objet.ref, objet.image_urls]
      end
    end
  end

  # rake "objets:import_scle[../collectif-objets-data/pop-scle-column.csv]"
  task :import_scle, [:path] => :environment do |_, args|
    puts "before: #{Objet.where.not(palissy_SCLE: nil).count} objets have SCLE"
    for row in CSV.read(args[:path], headers: true) do
      objet = Objet.find_by(palissy_REF: row["palissy_REF"])
      next unless objet

      objet.update!(palissy_SCLE: row["SCLE"])
    end
    puts "after: #{Objet.where.not(palissy_SCLE: nil).count} objets have SCLE"
  end

  # rake "objets:destroy_without_communes"
  task :destroy_without_communes, [:path] => :environment do |_, args|
    objets = Objet.where(commune_code_insee: [nil, ""])
    puts "before: #{objets.count} objets don't have a commune code insee"
    objets.each do |objet|
      puts "- https://www.pop.culture.gouv.fr/notice/palissy/#{objet.palissy_REF} (id #{objet.id})"
      if objet.recensements.any?
        puts "has recensements, skipping!"
        next
      end
      objet.destroy!
      puts "destroyed!"
    end
  end
end
