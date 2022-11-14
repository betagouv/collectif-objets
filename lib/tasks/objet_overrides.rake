# frozen_string_literal: true

require "csv"

namespace :objet_overrides do

  PHOTOS_HOST = "https://collectif-objets-photos-overrides.s3.fr-par.scw.cloud"

  # rake "objet_overrides:import[../collectif-objets-data/2022_11_ipamela_hautemarne.fixed.csv]"
  task :import, [:path] => :environment do |_, args|
    source = "2022_11_ipamela"
    ObjetOverride.where(source:).delete_all
    photos_by_ref = {}
    for row in CSV.read(args[:path], headers: true, col_sep: ";") do
      photos_by_ref[row["REF"]] ||= []
      photos_by_ref[row["REF"]] << "#{PHOTOS_HOST}/#{source}/#{row["file_name"]}"
    end
    puts "upserting #{photos_by_ref.count} objet overrides..."
    photos_by_ref.each do |ref, image_urls|
      ObjetOverride
        .where(palissy_REF: ref)
        .first_or_initialize(palissy_REF: ref)
        .tap { _1.assign_attributes(image_urls:, source:) }
        .save!
    end
    puts "done upserting #{photos_by_ref.count} rows!"
  rescue ActiveRecord::RecordInvalid => e
    puts "record invalid #{e.record.errors.full_messages}"
    raise e
  end

  # rake "objet_overrides:isolate_files[../collectif-objets-data/2022_11_ipamela_hautemarne.csv]"
  task :isolate_files, [:path] => :environment do |_, args|
    PHOTOS_PATH = "/Users/adipasquale/Downloads/ipamela/Photos/Images".freeze
    ISOLATED_PATH = "/Users/adipasquale/Downloads/ipamela/isolated".freeze

    fixed_path = args[:path].gsub(".csv", ".fixed.csv")
    counter = 0
    CSV.open(fixed_path, "wb") do |fixed_csv|
      fixed_csv << ["file_name", "REF"]
      CSV.read(args[:path], headers: true, col_sep: ";").each do |row|
        filename = row["file_name"]
        filename.gsub!(/_V\./, "_P.").gsub!(/\.JPG$/, ".jpg")
        path = "#{PHOTOS_PATH}/#{filename}"
        isolated_path = "#{ISOLATED_PATH}/#{filename}"
        if File.file?(path)
          `cp #{path} #{isolated_path}`
          fixed_csv << [path, row["REF"]]
          counter += 1
        else
          puts "file #{filename} not found"
        end
      end
    end
    puts "copied #{counter} photo files to #{ISOLATED_PATH}, new csv is #{fixed_path}"
  end
end

# {https://collectif-objets-photos-overrides.s3.fr-par.scw.cloud//2022_09_ariege/PM09001000_photo_0.JPG}
