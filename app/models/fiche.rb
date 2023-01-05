# frozen_string_literal: true

class Fiche
  ANCIEN_IDS_MAPPING = {
    vol: :depot_plainte,
    securisation: :securisation,
    nuisibles: :entretien_edifices
  }.freeze

  def self.directory_path = "contenus/fiches"
  def self.cache_prefix = "fiches"

  include MarkdownModelConcern

  def title = frontmatter_data.fetch(:titre)
  def ancien_id = frontmatter_data[:ancien_id]

  def table_of_contents_html
    kramdown_elt_to_list_html(kramdown_doc.to_toc)
  end

  private

  def kramdown_elt_to_list_html(elt)
    return nil if elt.children.empty?

    "<ol>\n#{elt.children.map { kramdown_elt_to_list_item_html(_1) }.join("\n")}\n</ol>\n"
  end

  def kramdown_elt_to_list_item_html(elt)
    "<li><a href='##{elt.attr[:id]}'>#{elt.value.options[:raw_text]}</a>#{kramdown_elt_to_list_html(elt)}</li>"
  end
end
