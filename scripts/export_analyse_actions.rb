# frozen_string_literal: true

# rails runner scripts/export_analyse_actions.rb

require "csv"

def recensements
  Recensement
    .where("cardinality(analyse_actions) >= 1")
    .includes(:conservateur, objet: [:commune])
    .order("communes.code_insee, conservateurs.id")
end

def recensement_to_row(recensement)
  [
    recensement.commune.code_insee,
    recensement.commune.nom,
    recensement.conservateur.email,
    recensement.objet.palissy_REF,
    recensement.objet.palissy_TICO
  ] + ACTIONS.map { recensement.analyse_actions.include?(_1) ? "1" : "" } +
    [
      recensement.id,
      recensement.updated_at,
      recensement.analyse_actions.join(" ")
    ]
end

fixed_path = Tempfile.create(%w[analyse_actions .csv])
ACTIONS = %w[securiser entretenir restaurer identifier localiser].freeze
CSV.open(fixed_path, "wb") do |csv|
  csv << (
    %w[code_insee commune conservateur palissy_REF palissy_TICO] +
    ACTIONS +
    %w[recensement_id updated_at analyse_actions]
  )
  recensements.find_each { csv << recensement_to_row(_1) }
end
puts "fixed_path #{fixed_path.path}"

# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
