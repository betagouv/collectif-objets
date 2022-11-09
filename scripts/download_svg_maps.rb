# frozen_string_literal: true

rm `tmp/*.json.gz`
rm `tmp/*.json`
rm `tmp/*.svg`

departement = "54"
puts "starting departement #{departement}..."
url = "https://cadastre.data.gouv.fr/data/etalab-cadastre/2022-10-01/geojson/departements/#{departement}/cadastre-#{departement}-communes.json.gz"

`curl #{url} > tmp/#{departement}.json.gz`
`gzip -d tmp/#{departement}.json.gz`
`mapshaper tmp/#{departement}.json -simplify 10% -o format=svg svg-data=nom tmp/#{departement}.svg`

puts "finished departement #{departement}..."
