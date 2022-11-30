# frozen_string_literal: true

class Objet < ApplicationRecord
  include ActionView::Helpers::TextHelper # for truncate

  scope :with_images, -> { where("cardinality(palissy_photos) >= 1") }
  belongs_to :commune, foreign_key: :palissy_INSEE, primary_key: :code_insee, optional: true, inverse_of: :objets
  belongs_to :edifice, optional: true
  has_many :recensements, dependent: :restrict_with_exception

  scope :with_photos_first, -> { order('cardinality(palissy_photos) DESC, LOWER(objets."palissy_TICO") ASC') }
  scope :order_by_recensement_priorite, -> { joins(:recensements).order(Arel.sql(Recensement::SQL_ORDER_PRIORITE)) }
  def self.order_by_recensement_priorite_array(objets_arel)
    objets_arel.to_a.sort_by { _1.recensements.to_a.any?(&:prioritaire?) ? 0 : 1 }
  end

  after_create { RefreshCommuneRecensementRatioJob.perform_async(commune.id) if commune }
  after_destroy { RefreshCommuneRecensementRatioJob.perform_async(commune.id) if commune }

  delegate :departement, to: :commune

  # old column names still used in code for reads
  alias_attribute :nom, :palissy_TICO
  alias_attribute :categorie, :palissy_CATE
  alias_attribute :commune_nom, :palissy_COM
  alias_attribute :commune_code_insee, :palissy_INSEE
  # alias_attribute :departement, :palissy_DPT
  alias_attribute :crafted_at, :palissy_SCLE
  alias_attribute :last_recolement_at, :palissy_DENQ
  alias_attribute :nom_dossier, :palissy_DOSS
  alias_attribute :edifice_nom, :palissy_EDIF
  alias_attribute :emplacement, :palissy_EMPL

  def edifice_nom_formatted
    if edifice_nom == "église" && commune.present?
      "Une église de #{commune.nom}"
    else
      edifice_nom&.capitalize
    end
  end

  def first_palissy_photo_url
    palissy_photos.any? && palissy_photos.first["url"]
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

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.select_best_objet_in_list(objets_arr)
    current_arr = objets_arr
    [
      ->(obj) { obj.palissy_photos.any? },
      ->(obj) { obj.nom.exclude?(";") },
      ->(obj) { obj.nom.match?(/[A-Z]/) },
      ->(obj) { obj.edifice_nom.present? },
      ->(obj) { obj.edifice_nom&.match?(/[A-Z]/) },
      ->(obj) { obj.emplacement.blank? }
    ].each do |filter_fun|
      filtered_arr = current_arr.filter { filter_fun.call(_1) }
      current_arr = filtered_arr if filtered_arr.any?
    end
    current_arr.first
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
