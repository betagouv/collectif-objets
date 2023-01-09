class RenameAnalysesFiches < ActiveRecord::Migration[7.0]
  MAPPING = {
    "vol" => "depot_plainte",
    "securisation" => "securisation",
    "nuisibles" => "entretien_edifices"
  }.freeze
  MAPPING_INVERT = MAPPING.invert.freeze

  def up
    recensements.find_each do |recensement|
      recensement.update_columns(analyse_fiches: recensement.analyse_fiches.map { MAPPING.fetch(_1, _1) })
    end
  end

  def down
    recensements.find_each do |recensement|
      recensement.update_columns(analyse_fiches: recensement.analyse_fiches.map { MAPPING_INVERT.fetch(_1, _1) })
    end
  end

  private

  def recensements
    Recensement.where("cardinality(analyse_fiches) >= 1")
  end
end
