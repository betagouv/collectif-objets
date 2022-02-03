require 'csv'

namespace :objets do
  desc "imports objets from airtable CSV"
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
      recolement_status: "Statut recensement"
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

  # rake objets:import_images[../collectif-objets-files/pop-export-custom-marne-51.csv]
  task :import_images, [:path] => :environment do |_, args|
    puts "before: #{Objet.where("cardinality(image_urls) >= 1").count} objets have photos"
    for row in CSV.read(args[:path], headers: true, col_sep: ";") do
      row_parameterized = row.to_h.transform_keys(&:parameterize)
      next if row_parameterized["ref"].blank? || row_parameterized["video"].blank?
      image_urls = row_parameterized["video"].split(";").map do |video_ref|
        "http://www2.culture.gouv.fr/Wave/image/memoire/" + video_ref.sub(/^mem\//, "")
      end
      objet = Objet.find_by(ref_pop: row_parameterized["ref"])
      next unless objet
      objet.image_urls = image_urls
      objet.save!
    end
    puts "after: #{Objet.where("cardinality(image_urls) >= 1").count} objets have photos"
  end

  # rake objets:import_insee[../collectif-objets-files/pop-export-custom-marne-51.csv]
  task :import_insee, [:path] => :environment do |_, args|
    puts "before: #{Objet.where.not(commune_code_insee: nil).count}/#{Objet.count} objets have insee code"
    for row in CSV.read(args[:path], headers: true, col_sep: ";") do
      row_parameterized = row.to_h.transform_keys(&:parameterize)
      next if row_parameterized["ref"].blank? || row_parameterized["insee"].blank?
      objet = Objet.find_by(ref_pop: row_parameterized["ref"])
      next unless objet
      objet.commune_code_insee = row_parameterized["insee"]
      objet.save!
    end
    puts "after: #{Objet.where.not(commune_code_insee: nil).count}/#{Objet.count} objets have insee code"
  end
end
