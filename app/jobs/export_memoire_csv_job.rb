# frozen_string_literal: true

class ExportMemoireCsvJob
  include Sidekiq::Job
  sidekiq_options retry: 0

  def perform(pop_export_id)
    @pop_export = PopExport.find(pop_export_id)
    @pop_export.csv.attach(io:, filename:, content_type: "text/csv")
  end

  private

  def io
    StringIO.new(
      CSV.generate do |csv|
        csv << MemoireExportPhoto::COLS
        recensement_photos.each do |photo|
          csv << photo.cols_values
        end
      end
    )
  end

  def recensement_photos
    @recensement_photos ||= MemoireExportPhoto.from_recensements(@pop_export.recensements)
  end

  def filename = "export_memoire_#{@pop_export.departement_code}_#{@pop_export.timestamp}.csv"
end
