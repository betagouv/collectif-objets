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
  validates :edifice_ids, presence: true, unless: :all_edifices?
  before_validation :filter_invalid_edifice_ids

  before_update :reset_notified_if_granted_changed
  before_update :grant_all_edifices_if_all_edifices_selected

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

  def edifice?(edifice)
    edifice_ids.include?(edifice.id)
  end

  def edifices
    if all_edifices?
      commune.edifices
    elsif edifice_ids.empty?
      Edifice.none
    else
      commune.edifices.where(id: edifice_ids)
    end
  end

  private

  def reset_notified_if_granted_changed
    self.notified = false if granted_changed?
  end

  def filter_invalid_edifice_ids
    return unless commune && edifice_ids.any?

    self.edifice_ids = edifice_ids.select { |id| commune.edifice_ids.include?(id) }
  end

  def grant_all_edifices_if_all_edifices_selected
    self.all_edifices = all_edifices? || edifice_ids.to_set == commune.edifice_ids.to_set
  end
end
