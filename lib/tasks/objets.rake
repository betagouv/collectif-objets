# frozen_string_literal: true

require "csv"

namespace :objets do

  # rake objets:export
  desc "export"
  task :export, [:path] => :environment do
    path = File.join(Rails.root, "tmp", "objets_datasette.csv")
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

      client = Synchronizer::ApiClientSql.objets
      progressbar = ProgressBar.create(total: 290_648, format: "%t: |%B| %p%% %e %c/%u")
      client.iterate_batches do |rows|
        Synchronizer::Objets::RevisionsBatch.new(rows).revisions.each do |revision|
          csv << headers.map { |header| revision.attributes[header]&.strip }
          progressbar.increment
        end
      end
      puts "exported #{progressbar.total} objets to #{path}"
    end
  end
end

