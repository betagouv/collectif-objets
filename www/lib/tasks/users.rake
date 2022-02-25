# frozen_string_literal: true

require "csv"

namespace :users do

  # rake "users:create_team[../collectif-objets-data/rails-team-emails.csv]"
  desc "create team users"
  task :create_team, [:path] => :environment do |_, args|
    commune = Commune.find_by_code_insee(26220)
    for row in CSV.read(args[:path], headers: true) do
      email = row["email"]
      puts "creating user #{email}..."
      User.create_with(commune: commune).find_or_create_by(email:)
    end
    puts "done!"
  end

  # rake "users:import[../collectif-objets-data/sib-import-470-users-campagne-marne.csv]"
  desc "import"
  task :import, [:path] => :environment do |_, args|
    for row in CSV.read(args[:path], headers: true) do
      commune = Commune.find_by_code_insee(row["code_insee"])
      if commune.nil?
        raise "⛔️ could not find commune #{row["code_insee"]}"
      end
      magic_token = row["TMP_MAGIC_LINK"].split("=")[-1]
      email = row["EMAIL"]
      puts "creating user #{email} (#{commune.nom}) with magic token #{magic_token}..."
      user = User.find_or_create_by(email:)
      user.update!(commune:, magic_token: )
    end
    puts "done!"
  end
end
