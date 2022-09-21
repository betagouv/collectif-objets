# frozen_string_literal: true

require "csv"

namespace :objet_overrides do

  PHOTOS_HOST = "https://collectif-objets-photos-overrides.s3.fr-par.scw.cloud/"

  # rake "objet_overrides:import[../collectif-objets-data/2022_09_objets_overrides_ariege_09.csv]"
  task :import, [:path] => :environment do |_, args|
    counter = 0
    ObjetOverride.delete_all
    for row in CSV.read(args[:path], headers: true) do
      ObjetOverride
        .where(palissy_REF: row["REF"])
        .first_or_initialize(
          palissy_REF: row["REF"],
          plan_objet_id: row["hmom"],
          image_urls: row["new_filenames"].split("|").map { "#{PHOTOS_HOST}/2022_09_ariege/#{_1}" }
        )
        .save!
      counter += 1
    end
    puts "done import #{counter} rows!"
  rescue ActiveRecord::RecordInvalid => e
    puts "waza #{e.record.errors.full_messages}"
    raise e
  end
end

# {https://collectif-objets-photos-overrides.s3.fr-par.scw.cloud//2022_09_ariege/PM09001000_photo_0.JPG}
