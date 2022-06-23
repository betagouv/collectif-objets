# frozen_string_literal: true

require "csv"
require 'securerandom'

namespace :conservateurs do

  # rake "conservateurs:import[../../collectif-objets-data/2022_06_conservateurs_caoa_annuaire.csv]"
  task :import, [:path] => :environment do |_, args|
    for row in CSV.read(args[:path], headers: true) do
      uniq = { email: row["email"].strip }
      match_data = /^([A-ZÊ' \-]{2,30}) ([A-Z][a-zA-Z \-éàçèùëêô]{2,30})$/.match(row["full_name"])
      raise "could not parse full_name #{row["full_name"]}" unless match_data
      last_name, first_name = match_data.to_a.from(1)
      conservateur = Conservateur.find_by(uniq) || Conservateur.new(uniq)
      conservateur.assign_attributes(
        departements: [row["departement"]], first_name:, last_name:
      )
      res = conservateur.save
      if res
        puts "upserted conservateur #{conservateur.email}"
      else
        puts "could not upsert conservateur #{conservateur.email} : #{conservateur.errors.full_messages.join(", ")}"
      end
    end
    puts "done!"
  end

end
