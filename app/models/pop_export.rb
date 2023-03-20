# frozen_string_literal: true

class PopExport < ApplicationRecord
  belongs_to :departement, foreign_key: :departement_code, inverse_of: :pop_exports
  validates :base, inclusion: { in: %w[palissy memoire] }
  has_many(
    :recensements_memoire,
    class_name: "Recensement",
    foreign_key: :pop_export_memoire_id,
    inverse_of: :pop_export_memoire,
    dependent: :nullify
  )
  has_many(
    :recensements_palissy,
    class_name: "Recensement",
    foreign_key: :pop_export_palissy_id,
    inverse_of: :pop_export_palissy,
    dependent: :nullify
  )
  has_many :photos_attachments, through: :recensements_memoire
  has_one_attached :zip
  has_one_attached :csv
  scope :palissy, -> { where(base: "palissy") }
  scope :memoire, -> { where(base: "memoire") }

  def recensement_photos_attachments
    ActiveStorage::Attachment
      .where(record_type: "Recensement")
      .joins("LEFT JOIN recensements ON recensements.id = active_storage_attachments.record_id")
      .joins("LEFT JOIN objets ON objets.id = recensements.objet_id")
      .joins('LEFT JOIN communes ON communes.code_insee = objets."palissy_INSEE"')
      .where(recensements: { pop_export_memoire_id: id })
      .order('communes.nom ASC, objets."palissy_REF" ASC')
  end

  def timestamp = created_at.strftime("%Y_%m_%d-%HH%M")

  def to_s = "Export #{base.capitalize} ##{id}"
end
