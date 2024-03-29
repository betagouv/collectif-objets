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

  def table_of_contents_html
    kramdown_elt_to_list_html(kramdown_doc.to_toc)
  end

  private

  def kramdown_elt_to_list_html(elt)
    return nil if elt.children.empty?

    "<ul>\n#{elt.children.map { kramdown_elt_to_list_item_html(_1) }.join("\n")}\n</ul>\n"
  end

  def kramdown_elt_to_list_item_html(elt)
    "<li><a href='##{elt.attr[:id]}'>#{elt.value.options[:raw_text]}</a>#{kramdown_elt_to_list_html(elt)}</li>"
  end
end
