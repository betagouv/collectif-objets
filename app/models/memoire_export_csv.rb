# frozen_string_literal: true

class MemoireExportCsv
  def initialize(pop_export)
    @pop_export = pop_export
  end

  def recensement_photos
    @recensement_photos ||= MemoireExportPhoto.from_recensements(@pop_export.recensements)
  end

  def to_s
    CSV.generate do |csv|
      csv << MemoireExportPhoto::COLS
      recensement_photos.each do |photo|
        csv << photo.cols_values
      end
    end
  end

  def filename = "memoire_#{@pop_export.departement_code}_#{@pop_export.timestamp}.csv"
end
