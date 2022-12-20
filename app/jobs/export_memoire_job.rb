# frozen_string_literal: true

require "zip"

class ExportMemoireJob
  include Sidekiq::Job

  def perform(pop_export_id)
    @pop_export = PopExport.find(pop_export_id)
    download_and_zip_attachments
    @pop_export.zip.attach(io: zip_file, filename:, content_type: "application/zip")
  ensure
    zip_file.close
    zip_file.unlink
  end

  private

  def download_and_zip_attachments
    progress = ProgressBar.create(total: attachments.count, format: "%t: |%B| %p%% %e")
    Zip::OutputStream.open(zip_file) do |zos|
      attachments.each do |attachment|
        zos.put_next_entry(attachment.memoire_REFIMG)
        zos.print attachment.download
        progress.increment
      end
    end
    zip_file.rewind
  end

  def attachments = @pop_export.photos_attachments

  def zip_file
    @zip_file ||= Tempfile.new(filename)
  end

  def filename
    "export_memoire_photos_#{@pop_export.departement_code}_#{@pop_export.timestamp}.zip"
  end
end
