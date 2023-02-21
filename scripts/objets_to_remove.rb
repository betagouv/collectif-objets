# frozen_string_literal: true

VALID_DOSS_VALUES = ["dossier individuel", "dossier avec sous-dossier", "individuel", "dossier indiviuel",
                     "dossier avec sous-dossiers"].freeze
INVALID_MANQUANT_VALUES = %w[manquant volé].freeze
INVALID_PROT_VALUES = %w[déclassé].freeze
INVALID_STAT_VALUES = ["propriété de l'Etat", "propriété de l'Etat (?)"].freeze

excluded_objets_query = <<~SQL.squish
  SELECT "REF", "DOSS", "MANQUANT", "PROT", "STAT"
  FROM palissy
  WHERE (
    "DOSS" NOT IN ('dossier individuel', 'dossier avec sous-dossier', 'individuel', 'dossier indiviuel', 'dossier avec sous-dossiers')
    OR "MANQUANT" IN ('manquant', 'volé')
    OR "PROT" = 'déclassé'
    OR "propriété de l'Etat" IN (SELECT VALUE FROM json_each([palissy].[STAT]))
    OR "propriété de l'Etat (?)" IN (SELECT VALUE FROM json_each([palissy].[STAT]))
  )
  ORDER BY palissy.REF
SQL

excluded_objets = Synchronizer::ApiClientSql.new(
  excluded_objets_query,
  logger: Rails.logger
)

puts "total rows matched: #{excluded_objets.total_rows}"

palissy_rows = []
excluded_objets.iterate_batches { palissy_rows += _1 }
# puts palissy_rows

def exclude_reason(palissy_row)
  return "DOSS" if VALID_DOSS_VALUES.exclude?(palissy_row["DOSS"])
  return "MANQUANT" if INVALID_MANQUANT_VALUES.include?(palissy_row["MANQUANT"])
  return "PROT" if INVALID_PROT_VALUES.include?(palissy_row["PROT"])
  return "STAT" if INVALID_STAT_VALUES.intersect?(JSON.parse(palissy_row["STAT"]))
end

to_exclude = Hash.new []
# excluded_objets.iterate_batches do |palissy_rows|
palissy_rows.each_slice(1000) do |rows|
  Objet.where(palissy_REF: rows.pluck("REF")).find_each do |objet|
    puts "objet should be excluded #{objet.id}"
    row = rows.find { _1["REF"] == objet.palissy_REF }
    to_exclude[exclude_reason(row)] += [objet.palissy_REF]
  end
end
puts "#{to_exclude.values.flatten.count} objets to remove : "
# pp to_exclude
