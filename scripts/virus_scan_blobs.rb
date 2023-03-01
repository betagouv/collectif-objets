raise StandardError, "ratonvirus is not configured" unless Ratonvirus.scanner.available?

progressbar = ProgressBar.create(total: ActiveStorage::Blob.count, format: "%t: |%B| %p%% %e")

ActiveStorage::Blob.all.order(key: :desc).find_in_batches(batch_size: 100) do |blobs|
  puts "Scanning 100 blobs from #{blobs.first.key}…"

  blobs.each do |blob|
    blob.open do |file|
      puts "There is a virus in blob #{blob.key}" if Ratonvirus.scanner.virus?(file.path)
    end
    progressbar.increment
  end
end

# ActiveStorage::Blob.select(:key).all.find_each { AntivirusScanBlobJob.perform_async(_1.key) }
