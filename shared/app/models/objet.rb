# frozen_string_literal: true

class Objet < ApplicationRecord
  include ActionView::Helpers::TextHelper # for truncate

  scope :with_images, -> { where("cardinality(image_urls) >= 1") }
  belongs_to :commune, foreign_key: :palissy_INSEE, primary_key: :code_insee, optional: true, inverse_of: :objets
  has_many :recensements, dependent: :restrict_with_exception
  belongs_to :conservateur, optional: true # for notes_conservateur

  scope :with_photos_first, -> { order('cardinality(image_urls) DESC, LOWER(objets."palissy_DENO") ASC') }

  after_create { RefreshCommuneRecensementRatioJob.perform_async(commune.id) if commune }
  after_destroy { RefreshCommuneRecensementRatioJob.perform_async(commune.id) if commune }

  # old column names still used in code for reads
  alias_attribute :nom, :palissy_DENO
  alias_attribute :categorie, :palissy_CATE
  alias_attribute :commune_nom, :palissy_COM
  alias_attribute :commune_code_insee, :palissy_INSEE
  alias_attribute :departement, :palissy_DPT
  alias_attribute :crafted_at, :palissy_SCLE
  alias_attribute :last_recolement_at, :palissy_DENQ
  alias_attribute :nom_dossier, :palissy_DOSS
  alias_attribute :edifice_nom, :palissy_EDIF
  alias_attribute :emplacement, :palissy_EMPL
  alias_attribute :nom_courant, :palissy_TICO

  def self.displayable
    in_str = Commune::DISPLAYABLE_DEPARTEMENTS.map { "'#{_1}'" }.join(", ")
    where.not(palissy_DENO: nil)
      .where.not(commune: nil)
      .where("SUBSTR(\"palissy_INSEE\", 0, 3) IN (#{in_str})")
  end

  def nom_formatted
    (TICO || DENO).capitalize
  end

  def edifice_nom_formatted
    if edifice_nom == "église" && commune.present?
      "Une église de #{commune.nom}"
    else
      edifice_nom&.capitalize
    end
  end

  def first_image_url
    image_urls&.first
  end

  def nom_with_ref_pop
    truncate("#{palissy_REF} #{nom}", length: 40)
  end

  def current_recensement
    recensements.first
  end

  def recensement?
    current_recensement.present?
  end

  def recensable?
    current_recensement.nil? && commune.objets_recensable?
  end
end
