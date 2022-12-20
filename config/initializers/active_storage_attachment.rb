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


  private

  def file_extension
    {"image/jpeg" => "jpg", "image/png" => "png"}.fetch(blob.content_type)
  end
end

module RecensementPhoto
  extend ActiveSupport::Concern
  included do
    belongs_to :recensement, foreign_key: 'record_id', optional: true
    has_one :objet, through: :recensement
    has_one :commune, through: :objet
    has_one :departement, through: :commune
    delegate :memoire_sequence_name, to: :departement
    after_save :set_memoire_number, if: :recensement?
  end

  def recensement?
    record_type == 'Recensement'
  end

  def recensement
    recensement? ? super : nil
  end

  def set_memoire_number
    return if memoire_number.present? || !recensement?

    ActiveRecord::Base.connection.execute \
      "UPDATE active_storage_attachments SET memoire_number = nextval('#{memoire_sequence_name}') WHERE id = #{id};"
    reload
  end

  def memoire_export_photo
    return unless recensement?

    MemoireExportPhoto.new(attachment: self, recensement:)
  end

  %w[LBASE REF REFIMG NUMP DATPV COULEUR OBS COM DOM EDIF COPY TYPDOC IDPROD LIEUCOR].each do |col|
    delegate "memoire_#{col}", to: :memoire_export_photo, allow_nil: true
  end
end


ActiveSupport.on_load(:active_storage_attachment) do
  ActiveStorage::Attachment.include Rotation
  ActiveStorage::Attachment.include RecensementPhoto
end
