# frozen_string_literal: true

class Recenseur < ApplicationRecord
  include SessionCodeAuthenticatable

  # rubocop:disable Style/WordArray -> Symbol enums are buggy up until Rails 8.1
  enum :status, ["pending", "accepted", "rejected", "optout"].index_by(&:itself), default: :pending, validate: true
  # rubocop:enable Style/WordArray

  has_many :accesses, class_name: "RecenseurAccess", dependent: :delete_all, inverse_of: :recenseur
  has_many :communes, through: :accesses
  has_many :departements, through: :communes

  scope :without_access, -> { where.missing(:accesses) }

  normalizes :email, with: ->(email) { email.downcase.strip }
  validates  :email, presence: true, uniqueness: true, if: :email_changed?

  attr_accessor :impersonating

  before_create :set_nom

  delegate :human_attribute_name, to: :class

  def to_s = nom
  def email = super || ""
  def notes = super || ""
  def human_status = human_attribute_name("status.#{status}")

  def append_to_notes(text)
    self.notes = [notes, text].compact_blank.join("\n")
  end

  # -------
  # RANSACK
  # -------

  def self.ransackable_attributes(_ = nil) = %w[email nom notes status]
  def self.ransackable_associations(_ = nil) = []
  ransacker(:nom, type: :string) { Arel.sql("unaccent(recenseurs.nom)") }
  ransacker(:notes, type: :string) { Arel.sql("unaccent(recenseurs.notes)") }
  ransacker(:status) { _1.table[:status] }

  private

  def set_nom
    self.nom = email.to_s.split("@").first if nom.blank?
  end
end
