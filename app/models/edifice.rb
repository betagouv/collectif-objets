# frozen_string_literal: true

class Edifice < ApplicationRecord
  belongs_to :commune, foreign_key: :code_insee, primary_key: :code_insee, optional: true, inverse_of: :edifices
  has_many :objets, dependent: :restrict_with_error

  validates :merimee_REF, uniqueness: true, if: -> { merimee_REF.present? }
  validates :slug, uniqueness: { scope: :code_insee }, if: -> { code_insee.present? }

  def self.ordered_by_nom
    order(Arel.sql("LOWER(UNACCENT(edifices.nom))"))
  end

  def self.find_or_create_and_synchronize!(ref)
    edifice = find_by(merimee_REF: ref)
    if edifice.nil?
      edifice = create!(merimee_REF: ref)
      Synchronizer::SynchronizeEdificeJob.perform_inline(ref:)
    end
    edifice
  end

  def self.slug_for(nom_edifice)
    return "" if nom_edifice.blank?

    s = nom_edifice.parameterize
    %w[le la l de d du paroissiale et].each { s = s.gsub("-#{_1}-", "-") }
    s = s.sub(/-paroissiale-/, "")
    s.sub(/-paroissiale$/, "")
    s
  end
end
