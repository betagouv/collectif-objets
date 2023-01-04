# frozen_string_literal: true

class Fiche
  def self.load_all
    all_ids.map { load_from_id(_1) }
  end

  def self.all_ids
    Rails.root.join("app/views/fiches")
      .glob("*.md")
      .map { File.basename(_1, ".md") }
  end

  def self.load_from_id(id)
    path = Rails.root.join("app/views/fiches/#{id}.md")
    parsed = FrontMatterParser::Parser.parse_file path
    new(id, parsed.content, parsed.front_matter.symbolize_keys)
  end

  def initialize(id, markdown_content, frontmatter_data)
    @id = id
    @markdown_content = markdown_content
    @frontmatter_data = frontmatter_data
  end

  attr_reader :id, :markdown_content, :frontmatter_data

  def title = frontmatter_data.fetch(:title)

  def kramdown_doc
    @kramdown_doc ||= Kramdown::Document.new(markdown_content)
  end

  delegate :to_html, to: :kramdown_doc

  def table_of_contents_html
    kramdown_elt_to_list_html(kramdown_doc.to_toc)
  end
end

def kramdown_elt_to_list_html(elt)
  return nil if elt.children.empty?

  "<ol>\n#{elt.children.map { kramdown_elt_to_list_item_html(_1) }.join("\n")}\n</ol>\n"
end

def kramdown_elt_to_list_item_html(elt)
  "<li><a href='##{elt.attr[:id]}'>#{elt.value.options[:raw_text]}</a>#{kramdown_elt_to_list_html(elt)}</li>"
end
