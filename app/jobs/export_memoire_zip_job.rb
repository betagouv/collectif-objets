# frozen_string_literal: true

require "zip"

class ExportMemoireZipJob < ApplicationJob
  discard_on StandardError, Exception

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
    @progressbar = ProgressBar.create(total: attachments.count, format: "%t: |%B| %p%% %e")
    @zip_output_stream = Zip::OutputStream.open(zip_file)
    attachments.each { download_and_zip_attachment(_1) }
    @zip_output_stream.close
    zip_file.rewind
  end

  def download_and_zip_attachment(attachment)
    @zip_output_stream.put_next_entry(attachment.memoire_REFIMG)
    @zip_output_stream.print attachment.download
    @progressbar.increment
    # rescue ActiveStorage::FileNotFoundError
    #   puts "file not found ! for attachment #{attachment.id} of recensement #{attachment.record_id}"
  end

  def attachments = @pop_export.photos_attachments

  def zip_file
    @zip_file ||= Tempfile.new(filename)
  end

  def filename
    "export_memoire_photos_#{@pop_export.departement_code}_#{@pop_export.timestamp}.zip"
  end
end
