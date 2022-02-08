# frozen_string_literal: true

require "csv"

HTML = <<~HTML
  <h3 style="padding:0 0 10px 0; margin: 0;">Jésus sur la croix</h3><i>Objet présent à <b>Martigues</b><br />dans l'Église du centre, nef droite</i>
HTML

def augment_row(row)
  row.to_h.symbolize_keys.merge(
    OBJETS_COMMUNE: Objet.count,
    TMP_METIERS: "https://collectif-objets.beta.gouv.fr/magic-authentication?magic-token=f0bd6817037843798eedf03c82556fc3Z",
    PROFESSION: HTML
  )
end

namespace :export do
  desc "augments CSV file for SIB import"
  task :augment_sib, [:path] => :environment do |_, args|
    new_rows = CSV.read(args[:path], headers: true).map { augment_row(_1) }
    puts new_rows.class
    new_path = args[:path].sub(/\.csv$/, ".augmented.csv")
    CSV.open(new_path, "wb", headers: true) do |csv|
      csv << new_rows.first.keys
      new_rows.each { csv << _1.values }
    end
    puts "wrote to #{new_path}!"
  end
end
