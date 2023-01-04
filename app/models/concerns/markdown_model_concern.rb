# frozen_string_literal: true

require "active_support/concern"

module MarkdownModelConcern
  extend ActiveSupport::Concern

  class_methods do
    def load_all
      all_ids.map { load_from_id(_1) }
    end

    def all_ids
      Rails.root.join(directory_path)
        .glob("*.md")
        .reverse
        .map { File.basename(_1, ".md") }
    end

    def load_from_id(id)
      Rails.cache.fetch("#{cache_prefix}-#{id}", expires_in: 10.days) do
        path = Rails.root.join("#{directory_path}/#{id}.md")
        parsed = FrontMatterParser::Parser.parse_file path
        new(id, parsed.content, parsed.front_matter.symbolize_keys)
      end
    end
  end

  def initialize(id, markdown_content, frontmatter_data)
    @id = id
    @markdown_content = markdown_content
    @frontmatter_data = frontmatter_data
  end

  attr_reader :id, :markdown_content, :frontmatter_data

  def kramdown_doc
    @kramdown_doc ||= Kramdown::Document.new(markdown_content)
  end

  delegate :to_html, to: :kramdown_doc
end
