# frozen_string_literal: true

class AntivirusScanBlobJob
  include Sidekiq::Job

  def perform(blob_key)
    # raise StandardError, "ratonvirus is not configured" unless Ratonvirus.scanner.available?

    blob = ActiveStorage::Blob.find_by(key: blob_key)
    raise unless blob

    Ratonvirus.scanner.scan(blob)
  end
end
