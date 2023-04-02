# frozen_string_literal: true

class ArticlePresse
  include MarkdownModelConcern

  def self.directory_path = "contenus/articles_presse"
  def self.cache_prefix = "article-presse"

  def title = frontmatter_data[:titre]
  def source = frontmatter_data[:source]
  def date = frontmatter_data[:date]
  def logo = frontmatter_data[:logo]
  def url = frontmatter_data[:url]
  def video = frontmatter_data[:video]
end
