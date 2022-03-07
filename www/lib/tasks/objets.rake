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
      ref_memoire: "Référence de l’illustration (Mémoire)",
      ref_pop: "Référence de la notice Palissy",
      nom: "Nom de l'objet",
      categorie: "CATE",
      commune: "COM",
      # commune_code_insee:
      departement: "DPT",
      crafted_at: "SOUR",
      last_recolement_at: "DENQ",
      nom_dossier: "DOSS",
      edifice_nom: "Edifice",
      emplacement: "Emplacement",
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

  # rake objets:import_images[../collectif-objets-data/pop-exports-custom]
  task :import_images, [:path] => :environment do |_, args|
    puts "before: #{Objet.with_images.count} objets have photos"
    iterate_files("#{args[:path]}/*.csv") do |row|
      next if row["ref"].blank? || row["video"].blank?

      image_urls = row["video"].split(";").map do |video_ref|
        "http://www2.culture.gouv.fr/Wave/image/memoire/" + video_ref.sub(/^mem\//, "")
      end
      objet = Objet.find_by(ref_pop: row["ref"])
      next unless objet

      objet.image_urls = image_urls
      objet.save!
    end
    puts "after: #{Objet.with_images.count} objets have photos"
  end

  # rake "objets:import_images_custom[../collectif-objets-data/tmp-146-objets-image-urls-to-import-in-rails.csv]"
  task :import_images_custom, [:path] => :environment do |_, args|
    puts "before: #{Objet.with_images.count} objets have photos"
    for row in CSV.read(args[:path], headers: true) do
      objet = Objet.find_by(ref_pop: row["ref_pop"])
      next unless objet

      objet.image_urls = JSON.parse(row["scrapped_image_urls"].gsub("'", '"'))
      objet.save!
    end
    puts "after: #{Objet.with_images.count} objets have photos"
  end

  # rake objets:import_insee[../collectif-objets-data/pop-exports-custom]
  task :import_insee, [:path] => :environment do |_, args|
    puts "before: #{Objet.where.not(commune_code_insee: nil).count}/#{Objet.count} objets have insee code"
    iterate_files("#{args[:path]}/*.csv") do |row|
      next if row["ref"].blank? || row["insee"].blank?

      objet = Objet.find_by(ref_pop: row["ref"])
      next unless objet

      objet.commune_code_insee = row["insee"]
      objet.save!
    end
    puts "after: #{Objet.where.not(commune_code_insee: nil).count}/#{Objet.count} objets have insee code"
  end

  # rake "objets:import_nom_courant[../collectif-objets-data/pop-exports-custom]"
  task :import_nom_courant, [:path] => :environment do |_, args|
    puts "after: #{Objet.where.not(nom_courant: nil).count}/#{Objet.count} objets have nom courant"
    iterate_files("#{args[:path]}/*.csv") do |row|
      next if row["ref"].blank? || row["tico"].blank?

      objet = Objet.find_by(ref_pop: row["ref"])
      next unless objet

      objet.nom_courant = row["tico"]
      objet.save!
    end
    puts "after: #{Objet.where.not(nom_courant: nil).count}/#{Objet.count} objets have nom courant"
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
    puts "before: #{Objet.where.not(crafted_at: nil).count} objets have SCLE"
    for row in CSV.read(args[:path], headers: true) do
      objet = Objet.find_by(ref_pop: row["REF"])
      next unless objet

      objet.update!(crafted_at: row["SCLE"])
    end
    puts "after: #{Objet.where.not(crafted_at: nil).count} objets have SCLE"
  end
end
