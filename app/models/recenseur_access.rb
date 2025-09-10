# frozen_string_literal: true

class RecenseurAccess < ApplicationRecord
  belongs_to :recenseur, touch: true
  belongs_to :commune
  has_one :departement, through: :commune

  scope :granted, -> { where(granted: true) }
  scope :pending, -> { where(granted: nil) }
  scope :newly_granted, -> { where(granted: true, notified: false) }
  scope :newly_revoked, -> { where(granted: false, notified: false) }
  scope :with_edifices, -> { where(all_edifices: true).or(where.not(edifice_ids: [])) }
  scope :sorted, -> { joins(:commune).order("communes.departement_code, communes.nom") }

  delegate :human_attribute_name, to: :class

  validates :commune, uniqueness: { scope: :recenseur_id }, if: :commune_id_changed?

  before_validation :filter_invalid_edifice_ids
  before_save :ensure_consistency, if: :commune
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

  def edifice?(edifice)
    edifice_ids.include?(edifice.id)
  end

  def all_edifices_selected?
    edifice_ids.sort == commune.edifice_ids.sort
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

  def edifice_ids_attributes=(attributes)
    selected_ids = []
    attributes.each_value.each do |edifice_and_checked_hash|
      edifice_id, checked = edifice_and_checked_hash.to_a.flatten
      selected_ids << edifice_id.to_i if checked.to_i.positive?
    end
    self.edifice_ids = selected_ids
  end

  private

  def reset_notified_if_granted_changed
    self.notified = false if granted_changed?
  end

  def filter_invalid_edifice_ids
    return unless commune

    self.edifice_ids = (edifice_ids || []).select { |id| commune.edifice_ids.include?(id) }
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def ensure_consistency
    # Grant all_edifices when granted becomes true
    if granted_changed? && granted? && (edifice_ids.empty? || all_edifices_selected?)
      self.all_edifices = true
      self.edifice_ids = commune.edifice_ids
    end

    # Toggle edifices when all_edifices changes
    self.edifice_ids = all_edifices? ? commune.edifice_ids : [] if granted? && all_edifices_changed?

    # Toggle all_edifices when edifice_ids changes
    return unless granted? && edifice_ids_changed?

    self.all_edifices = if edifice_ids.empty?
                          false
                        else
                          all_edifices_selected?
                        end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
