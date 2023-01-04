# frozen_string_literal: true

class ArticlePresse
  def self.load_all
    all_ids.map { load_from_id(_1) }
  end

  def self.all_ids
    Rails.root.join("contenus/articles_presse")
      .glob("*.md")
      .reverse
      .map { File.basename(_1, ".md") }
  end

  def self.load_from_id(id)
    Rails.cache.fetch("article-presse-#{id}", expires_in: 10.days) do
      path = Rails.root.join("contenus/articles_presse/#{id}.md")
      parsed = FrontMatterParser::Parser.parse_file path
      new(id, parsed.content, parsed.front_matter.symbolize_keys)
    end
  end

  def initialize(id, markdown_content, frontmatter_data)
    @id = id
    @markdown_content = markdown_content
    @frontmatter_data = frontmatter_data
  end

  attr_reader :id, :markdown_content, :frontmatter_data

  %i[titre source date logo url resume video].each do |att|
    define_method att, -> { frontmatter_data[att] }
  end

  def kramdown_doc
    @kramdown_doc ||= Kramdown::Document.new(markdown_content)
  end

  delegate :to_html, to: :kramdown_doc
end
