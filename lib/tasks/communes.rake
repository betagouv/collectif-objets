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

  task :fix_sib_lists, [:departement] => :environment do |_, args|
    departement = args[:departement]
    def load_contacts_from_sib(departement)
      contacts = ["cold", "enrolled", "started"].map do |key|
        [key, Co::SendInBlueClient.instance.get_list_contacts(departement, key).map{ _1[:email] }]
      end.to_h
      puts "in SIB lists for dpt #{departement} : "
      contacts.each { |key, contacts| puts "  - #{key} : #{contacts.count} contacts" }; nil
      contacts
    end
    contacts = load_contacts_from_sib(departement)
    communes = Commune.where(departement: )
    communes.enrolled.each do |commune|
      puts "commune enrolled - #{commune}"
      if contacts["cold"].include?(commune.users.first.email)
        puts " - moving to enrolled"
        TriggerSibContactEventJob.perform_inline(commune.id, "enrolled")
      else
        puts "  - commune is not in cold anymore"
      end
    end
    communes.where(status: ["started", "completed"]).each do |commune|
      puts "commune started or completed - #{commune}"
      if contacts["cold"].include?(commune.users.first.email)
        puts "  - moving to started"
        TriggerSibContactEventJob.perform_inline(commune.id, "started")
      else
        puts "  - commune is not in cold anymore"
      end
    end
    load_contacts_from_sib(departement) # to log
  end

end
