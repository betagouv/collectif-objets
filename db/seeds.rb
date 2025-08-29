raise if Rails.configuration.x.environment_specific_name == "production"

run "bin/rails r scripts/create_postgres_sequences_memoire_photos_numbers.rb"

return if Rails.env.test?

def run(command)
  puts "> #{command}"
  `#{command}`
end

puts "downloading seeds file from ..."
path = Rails.root.join("tmp/seeds.pgsql")
run("curl https://s3.fr-par.scw.cloud/collectif-objets-public/seeds.pgsql > #{path}")

db = Rails.configuration.database_configuration[Rails.env]
db_url = db["url"] || "postgresql://#{db["username"]}:#{db["password"]}@#{db["host"]}:#{db["port"]}/#{db["database"]}"

puts "restoring data to postgres db..."
run("pg_restore --data-only --no-owner --no-privileges --no-comments --dbname=#{db_url} #{path}")
puts "done"

Conservateur.create!(email: "conservateur@collectif.local", password: "123456789", departements: Departement.where(code: %w[06 09 12 19 26 51 52 86])) unless Conservateur.where(email: "conservateur@collectif.local").any?
