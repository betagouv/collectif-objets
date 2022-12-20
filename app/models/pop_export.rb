# frozen_string_literal: true

class PopExport < ApplicationRecord
  belongs_to :departement, foreign_key: :departement_code, inverse_of: :pop_exports
  validates :base, inclusion: { in: %w[palissy memoire] }
  has_many :pop_export_recensements, dependent: :delete_all, inverse_of: :pop_export
  has_many :recensements, through: :pop_export_recensements, inverse_of: :pop_exports
  has_many :photos_attachments, through: :recensements
  has_one_attached :zip
  has_one_attached :csv
  scope :palissy, -> { where(base: "palissy") }
  scope :memoire, -> { where(base: "memoire") }

  def recensement_photos_attachments
    ActiveStorage::Attachment
      .where(record_type: "Recensement")
      .joins("LEFT JOIN recensements ON recensements.id = active_storage_attachments.record_id")
      .joins("LEFT JOIN pop_export_recensements ON recensements.id = pop_export_recensements.recensement_id")
      .joins("LEFT JOIN objets ON objets.id = recensements.objet_id")
      .joins('LEFT JOIN communes ON communes.code_insee = objets."palissy_INSEE"')
      .where(pop_export_recensements: { pop_export_id: id })
      .order("communes.nom ASC")
  end

  def timestamp = created_at.strftime("%Y_%m_%d-%HH%M")

  def to_s = "Export #{base.capitalize} ##{id}"
end
