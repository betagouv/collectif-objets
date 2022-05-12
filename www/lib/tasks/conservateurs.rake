# frozen_string_literal: true

require "csv"
require 'securerandom'

namespace :conservateurs do

  # rake "conservateurs:import[../../collectif-objets-data/2022_04_liste_conservateurs.csv]"
  task :import, [:path] => :environment do |_, args|
    for row in CSV.read(args[:path], headers: true) do
      uniq = { email: row["email"].strip }
      conservateur = Conservateur.find_by(uniq) || Conservateur.new(uniq)
      conservateur.assign_attributes(
        departements: row["departements"]&.split(",")&.map(&:strip) || [],
        **row.to_h.slice("first_name", "last_name", "phone_number").transform_values { _1&.strip }
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
