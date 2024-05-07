# frozen_string_literal: true

require "csv"

class ExportMemoireCsvJob < ApplicationJob
  discard_on StandardError, Exception

  def perform(pop_export_id)
    @pop_export = PopExport.find(pop_export_id)
    # File.write("tmp/memoire.csv", io.read) # debug function
    @pop_export.csv.attach(io:, filename:, content_type: "text/csv")
  end

  private

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
    @recensement_photos ||= MemoireExportPhoto.from_recensements(recensements_memoire)
  end

  def recensements_memoire
    @recensements_memoire ||= @pop_export.recensements_memoire.includes(:objet).all
  end

  def filename = "export_memoire_#{@pop_export.departement_code}_#{@pop_export.timestamp}.csv"
end
