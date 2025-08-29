# frozen_string_literal: true

class Edifice < ApplicationRecord
  belongs_to :commune, foreign_key: :code_insee, primary_key: :code_insee, optional: true, inverse_of: :edifices
  has_many :objets, dependent: :nullify
  has_many :bordereaux, dependent: :nullify

  has_many :recenseurs, through: :commune

  validates :code_insee, presence: true
  validates :merimee_REF, uniqueness: true, if: -> { merimee_REF.present? }
  validates :slug, uniqueness: { scope: :code_insee }, if: -> { code_insee.present? }

  scope :with_objets, -> { where.not(objets: { id: nil }) }
  scope :with_objets_classés, -> { where.associated(:objets).merge(Objet.classés).group("edifices.id") }
  scope :with_objets_classés_ou_inscrits, lambda {
    where.associated(:objets)
    .merge(Objet.protégés)
    .group("edifices.id")
  }
  scope :ordered_by_nom, -> { order(Arel.sql("LOWER(UNACCENT(edifices.nom))")) }

  scope :with_objets_count, lambda {
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT objets.edifice_id, COUNT(*) AS objets_count
          FROM objets
          WHERE objets.edifice_id IS NOT NULL
          GROUP BY objets.edifice_id
        ) objets_counts ON objets_counts.edifice_id = edifices.id
      }
    ).select("edifices.*, COALESCE(objets_counts.objets_count, 0) AS objets_count")
  }

  scope :preloaded, lambda {
    with_objets.ordered_by_nom.includes(
      objets: [:commune, { recensement: [:photos_attachments, :photos_blobs] }]
    )
  }

  delegate :normalize_nom, to: :class

  # rubocop:disable Naming/MethodParameterName, Naming/VariableName
  def self.find_or_create_and_synchronize!(merimee_REF:, code_insee:)
    edifice = find_by(merimee_REF:)
    if edifice.nil?
      edifice = create!(merimee_REF:, code_insee:)
      Synchronizer::Edifices::SynchronizeOneJob.perform_now(ref: merimee_REF)
    end
    edifice
  end
  # rubocop:enable Naming/MethodParameterName, Naming/VariableName

  def self.slug_for(nom_edifice)
    return "" if nom_edifice.blank?

    s = nom_edifice.parameterize
    %w[le la l de d du paroissiale et].each { s = s.gsub("-#{_1}-", "-") }
    s = s.sub("-paroissiale-", "")
    s.sub(/-paroissiale$/, "")
    s
  end

  def self.normalize_nom(nom)
    nom.strip.upcase_first if nom.present?
  end

  def to_s
    "Édifice #{nom} #{merimee_REF ? "(#{merimee_REF})" : '(sans référence Mérimée)'} - commune #{code_insee}"
  end

  def nom = normalize_nom(super) || "édifice non renseigné"
end
