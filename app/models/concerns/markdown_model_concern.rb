# frozen_string_literal: true

module MarkdownModelConcern
  extend ActiveSupport::Concern

  class_methods do
    def all
      ids.map { find(_1) }
    end

    def directory_path
      "contenus/#{name.pluralize.underscore}"
    end

    def cache_prefix
      name.dasherize
    end

    def ids
      Rails.root.join(directory_path)
        .glob("*.md")
        .reverse
        .map { File.basename(_1, ".md") }
    end

    def find(id)
      Rails.cache.fetch("#{cache_prefix}-#{id}", expires_in: 10.days) do
        path = Rails.root.join("#{directory_path}/#{id}.md")
        raise ActiveRecord::RecordNotFound, path unless path.exist?

        parsed = FrontMatterParser::Parser.parse_file path
        new(id, parsed.content, parsed.front_matter.symbolize_keys)
      end
    end

    def find_each(&block)
      all.each(&block)
    end
  end

  def initialize(id, markdown_content, frontmatter_data)
    @id = id
    @markdown_content = markdown_content
    @frontmatter_data = frontmatter_data
  end

  attr_reader :id, :markdown_content, :frontmatter_data

  def title = frontmatter_data[:titre]

  def doc
    @doc ||= Kramdown::Document.new(markdown_content)
  end

  delegate :to_html, to: :doc

  def toc
    doc.to_toc.children.collect { |element| kramdown_elt_to_toc_item(element) }
  end

  private

  def kramdown_elt_to_toc_item(element)
    Struct.new("TocItem", :title, :id, :children) unless defined? Struct::TocItem
    Struct::TocItem.new(
      element.value.options[:raw_text],
      element.attr[:id],
      element.children.map { |child| kramdown_elt_to_toc_item(child) } || []
    )
  end

  def respond_to_missing?(name, _include_private = false)
    frontmatter_data.key? name
  end

  def method_missing(method, *_args)
    frontmatter_data[method]
  end
end
