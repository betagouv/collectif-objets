# frozen_string_literal: true

`rm -f tmp/*.json.gz`
`rm -f tmp/*.json`
`rm -f tmp/*.svg`

def prepare(departement)
  puts "starting departement #{departement}..."
  url = "https://cadastre.data.gouv.fr/data/etalab-cadastre/2022-10-01/geojson/departements/#{departement}/cadastre-#{departement}-communes.json.gz"

  final_path = Rails.root.join("public/svg-maps/communes-#{departement}.svg")

  `curl #{url} > tmp/#{departement}.json.gz`
  `gzip -d tmp/#{departement}.json.gz`
  `mapshaper tmp/#{departement}.json -simplify 10% -o format=svg svg-data=nom #{final_path}`
  # image optim removes data attributes
  # `/Applications/ImageOptim.app/Contents/MacOS/ImageOptim #{final_path} &> /dev/null`

  puts "finished departement #{departement}..."
end

# Departement.pluck(:code).each { prepare(_1) }
prepare("64")
