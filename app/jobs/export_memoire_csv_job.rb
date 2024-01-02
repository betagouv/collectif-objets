# frozen_string_literal: true

require "csv"

class ExportMemoireCsvJob < ApplicationJob
  sidekiq_options retry: 0

  def perform(pop_export_id)
    @pop_export = PopExport.find(pop_export_id)
    # File.write("tmp/memoire.csv", io.read) # debug function
    @pop_export.csv.attach(io:, filename:, content_type: "text/csv")
  end

  private

  def palissy_data
    @palissy_data ||= Synchronizer::ApiClientJson.objets(
      params: {
        REF__in: recensements_memoire.map(&:objet).map(&:palissy_REF).join(","),
        _col: %w[REF TICO CATE DATE SCLE AUTR INSEE ADRS LIEU],
        _json: %w[CATE DATE SCLE AUTR]
      },
      logger: Rails.logger, limit: 1000
    ).to_a
  end

  def io
    StringIO.new(
      CSV.generate(force_quotes: true) do |csv|
        csv << MemoireExportPhoto::COLS
        recensement_photos.each do |photo|
          csv << photo.cols_values
        end
      end
    )
  end

  def recensement_photos
    @recensement_photos ||= MemoireExportPhoto.from_recensements(recensements_memoire, palissy_data:)
  end

  def recensements_memoire
    @recensements_memoire ||= @pop_export.recensements_memoire.includes(:objet).all
  end

  def filename = "export_memoire_#{@pop_export.departement_code}_#{@pop_export.timestamp}.csv"
end
