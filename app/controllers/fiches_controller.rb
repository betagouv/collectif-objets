# frozen_string_literal: true

class FichesController < ApplicationController
  def index; end

  def show
    raise ArgumentError if %w[restaurer].exclude? params[:id]

    @title = frontmatter_data.fetch(:title)
    @markdown_content = Kramdown::Document.new(markdown_raw).to_html
  end

  private

  def markdown_path
    Rails.root.join("app", "views", "fiches", "#{params[:id]}.md")
  end

  def parsed_file
    @parsed_file ||= FrontMatterParser::Parser.parse_file markdown_path
  end

  def markdown_raw = parsed_file.content

  def frontmatter_data = parsed_file.front_matter.symbolize_keys
end
