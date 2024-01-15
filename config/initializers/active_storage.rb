# frozen_string_literal: true

Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy

class UnsafePurgeError < StandardError
  def initialize(blob)
    super "Purging a file from Active Storage service '#{blob.service_name}' is not allowed from env #{Rails.env}"
  end
end


module PreventErroneousPurgeBlob
  def purge
    return super if safe_purge?

    raise UnsafePurgeError, self
  end

  def safe_purge?
    Rails.env.production? || %w[scaleway_development test local].include?(service_name)
  end
end

module PreventErroneousPurgeAttachment
  def purge
    return super if safe_purge?

    raise UnsafePurgeError, blob
  end

  def safe_purge?
    Rails.env.production? || %w[scaleway_development test local].include?(blob.service_name)
  end
end

module Rotation
  def rotate!(degrees: 90)
    raise UnsafePurgeError, blob unless safe_purge?

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
  ActiveStorage::Attachment.prepend PreventErroneousPurgeAttachment
  ActiveStorage::Blob.prepend PreventErroneousPurgeBlob
end
