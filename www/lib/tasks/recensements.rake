# frozen_string_literal: true

require "csv"
require 'open-uri'
require 'json'

namespace :recensements do

  # rake "recensements:import[../../collectif-objets-data/airtable-recensements-reformatted.csv]"
  task :import, [:path] => :environment do |_, args|
    Recensement.destroy_all
    for row in CSV.read(args[:path], headers: true) do
      puts "processing #{row["ref_pop"]}.."
      objet = Objet.find_by_ref_pop(row["ref_pop"])
      raise "no objet found for #{row["ref_pop"]}" if objet.nil?
      raise "objet #{row["ref_pop"]} already has a recensement" if objet.recensements.any?
      # puts "row is #{row.to_h}"
      recensement = Recensement.new(
        objet:,
        recensable: row["localisation"] == "edifice_initial",
        skip_photos: true,
        **row.to_h.slice(
          "localisation",
          "edifice_nom",
          "etat_sanitaire_edifice",
          "etat_sanitaire",
          "securisation",
          "notes",
          "created_at"
        )
      )
      raise "errors for #{row["ref_pop"]} : #{recensement.errors.messages.values}" unless recensement.valid?
      recensement.save!

      JSON.parse(row["photo_urls"] || "[]").each do |image_url|
        puts "downloading #{File.basename(image_url)} -  #{image_url} ..."
        downloaded_file = URI.open(image_url)
        recensement.photos.attach(io: downloaded_file, filename: File.basename(image_url))
      end
    end
  end
end
