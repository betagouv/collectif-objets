# frozen_string_literal: true

class ArticlePresse
  include MarkdownModelConcern

  def self.directory_path = "contenus/articles_presse"
  def self.cache_prefix = "article-presse"
end
