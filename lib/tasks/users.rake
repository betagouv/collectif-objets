# frozen_string_literal: true

require "csv"
require 'securerandom'

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

  task :set_mailcatch_mails, [] => :environment do |_, args|
    raise if Rails.configuration.x.environment_specific_name == "production"

    User.includes(:commune).each do |user|
      user.update(
        email: "commune-#{user.commune.code_insee}@mailcatch.com"
      )
    rescue ActiveRecord::RecordNotUnique
    end
  end

end
