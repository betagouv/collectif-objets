# frozen_string_literal: true

require "csv"

namespace :blobs do
  task :purge_orphans, [:path] => :environment do |_, args|
    bucket_blob_ids = CSV.read(args[:path]).map { _1[0] }
    puts "first bucket blobs: #{bucket_blob_ids.first(3)}"
    db_blob_ids = ActiveStorage::Blob.pluck(:key)
    orphan_blob_ids = bucket_blob_ids - db_blob_ids
    puts "found #{orphan_blob_ids.count} orphans (#{bucket_blob_ids.count} in bucket but only #{db_blob_ids.count} in db)"
    orphan_blob_ids.each do |id|
      raise unless system("aws s3 rm s3://collectif-objets-staging/#{id}")
    end
  end
end
