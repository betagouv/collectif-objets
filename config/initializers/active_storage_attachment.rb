# frozen_string_literal: true

module Rotation
  def rotate!(degrees: 90)
    rotated_tempfile = nil
    blob.open do |original_tempfile|
      rotated_tempfile = ImageProcessing::Vips.source(original_tempfile).rotate(degrees).call
    end

    rotated_blob = ActiveStorage::Blob.create_and_upload!(
      io: rotated_tempfile,
      filename: filename
    )
    previous_blob = blob
    update!(blob: rotated_blob)
    previous_blob.purge_later
  end
end

ActiveSupport.on_load(:active_storage_attachment) do
  ActiveStorage::Attachment.include Rotation
end
