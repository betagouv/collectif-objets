# frozen_string_literal: true

class RecenseurAccess < ApplicationRecord
  belongs_to :recenseur, touch: true
  belongs_to :commune
  has_one :departement, through: :commune

  scope :granted, -> { where(granted: true) }
  scope :pending, -> { where(granted: nil) }
  scope :newly_granted, -> { where(granted: true, notified: false) }
  scope :newly_revoked, -> { where(granted: false, notified: false) }
  scope :sorted, -> { joins(:commune).order("communes.departement_code, communes.nom") }

  delegate :human_attribute_name, to: :class

  validates :commune, uniqueness: { scope: :recenseur_id }, if: :commune_id_changed?

  before_update :reset_notified_if_granted_changed

  def pending? = granted.nil?

  def human_status
    status = if pending?
               :pending
             elsif granted?
               :granted
             else
               :rejected
             end
    human_attribute_name("status.#{status}")
  end

  private

  def reset_notified_if_granted_changed
    self.notified = false if granted_changed?
  end
end
