# frozen_string_literal: true

class Fiche
  include MarkdownModelConcern

  def self.directory_path = "contenus/fiches"
  def self.cache_prefix = "fiches"
end
