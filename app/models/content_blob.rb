# frozen_string_literal: true

class ContentBlob
  include MarkdownModelConcern

  def self.directory_path = "contenus/content_blobs"
  def self.cache_prefix = "content-blob"
end
