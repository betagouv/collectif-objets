raise if Rails.configuration.x.environment_specific_name == "production"

path = Rails.root.join("tmp/seeds.pgsql")

def run(command)
  puts "> #{command}"
  `#{command}`
end

puts "downloading seeds file from ..."
run("curl https://s3.fr-par.scw.cloud/collectif-objets-public/seeds.pgsql > #{path}")

db = Rails.configuration.database_configuration[Rails.env]
db_url = db["url"]&.gsub("postgis", "postgresql") || "postgresql://#{db["username"]}:#{db["password"]}@#{db["host"]}:#{db["port"]}/#{db["database"]}"

puts "restoring data to postgres db..."
run("pg_restore --data-only --no-owner --no-privileges --no-comments --dbname=#{db_url} #{path}
")
puts "done"

AdminUser.create!(email: "admin@collectif.local", password: "123456789") unless AdminUser.where(email: "admin@collectif.local").any?
Conservateur.create!(email: "conservateur@collectif.local", password: "123456789", departements: Departement.where(code: %w[06 09 12 19 26 51 52 86])) unless Conservateur.where(email: "conservateur@collectif.local").any?
