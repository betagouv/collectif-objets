# frozen_string_literal: true

require "csv"

namespace :objets do

  # rake objets:export
  desc "export"
  task :export, [:path] => :environment do
    path = File.join(Rails.root, "tmp", "objets_data_culture.csv")
    headers = %w(
      palissy_REF
      palissy_DENO
      palissy_CATE
      palissy_SCLE
      palissy_DENQ
      palissy_COM
      palissy_INSEE
      palissy_DPT
      palissy_DOSS
      palissy_EDIF
      palissy_EMPL
      palissy_TICO
      palissy_DPRO
      palissy_PROT
      palissy_REFA
    )
    CSV.open(path, "wb") do |csv|
      csv << headers
      client = Synchronizer::Objets::ApiClientPalissy.new
      progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
      total = 0
      client.each_slice(1000) do |rows|
        all_objets_attributes_with_eager_loaded_records = Synchronizer::Objets::Batch.new(rows).all_objets_attributes_with_eager_loaded_records
        all_objets_attributes_with_eager_loaded_records.each do |objet_attributes, _eager_loaded_records|
          csv << headers.map { |header| objet_attributes[header.to_sym] }
          progressbar.increment
        end
        total += all_objets_attributes_with_eager_loaded_records.count
        (1000 - all_objets_attributes_with_eager_loaded_records.count).times { progressbar.increment }
      end
      puts "exported #{total} objets to #{path}"
    end
  end
end

