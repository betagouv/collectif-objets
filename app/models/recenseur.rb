# frozen_string_literal: true

class Recenseur < ApplicationRecord
  include SessionCodeAuthenticatable

  devise :timeoutable, timeout_in: 3.months

  # rubocop:disable Style/WordArray
  # Symbol enums are buggy up until Rails 8.1
  enum :status, ["pending", "accepted", "rejected", "optout"].index_by(&:itself), default: :pending, validate: true
  # rubocop:enable Style/WordArray

  generates_token_for(:optout)

  has_many :accesses, class_name: "RecenseurAccess", dependent: :delete_all, inverse_of: :recenseur
  has_many :granted_accesses, -> {
                                granted
                              }, class_name: "RecenseurAccess", dependent: :delete_all, inverse_of: :recenseur
  has_many :communes, through: :granted_accesses
  has_many :departements, through: :communes
  # rubocop:disable Rails/HasManyOrHasOneDependent
  has_many :new_accesses, -> { newly_granted }, class_name: "RecenseurAccess", inverse_of: :recenseur
  has_many :new_communes, class_name: "Commune", through: :new_accesses, source: :commune
  has_many :revoked_accesses, -> { newly_revoked }, class_name: "RecenseurAccess", inverse_of: :recenseur
  has_many :revoked_communes, class_name: "Commune", through: :revoked_accesses, source: :commune
  # rubocop:enable Rails/HasManyOrHasOneDependent

  scope :without_access, -> { where.missing(:accesses) }

  normalizes :email, with: ->(email) { email.downcase.strip }
  validates  :email, presence: true, uniqueness: true, if: :email_changed?

  attr_accessor :impersonating

  before_create :set_nom

  delegate :human_attribute_name, to: :class

  class << self
    def human_statuses
      statuses.keys.index_with { |status| human_attribute_name("status.#{status}") }
    end
  end

  def to_s = nom
  def email = super || ""
  def notes = super || ""
  def human_status = human_attribute_name("status.#{status}")
  def optout_token = generate_token_for(:optout)

  def append_to_notes(text)
    self.notes = [notes, text].compact_blank.join("\n")
  end

  def notify_access_granted? = accepted? && new_accesses.any?

  def notify_access_revoked? = accepted? && revoked_accesses.any?

  def commune?(commune)
    accesses.any? { |access| access.commune == commune }
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
