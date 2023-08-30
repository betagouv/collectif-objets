# frozen_string_literal: true

class Commune < ApplicationRecord
  belongs_to :departement, foreign_key: :departement_code, inverse_of: :communes

  include Communes::IncludeCountsConcern

  include AASM
  aasm column: :status, timestamps: true, whiny_persistence: true do
    state :inactive, initial: true, display: "Commune inactive"
    state :started, display: "Recensement démarré"
    state :completed, display: "Recensement terminé"

    event :start, before: :aasm_before_start do
      transitions from: :inactive, to: :started
    end
    event :complete, after: :aasm_after_complete do
      transitions from: :started, to: :completed
    end
    event :return_to_started, after: :aasm_after_return_to_started do
      transitions from: :completed, to: :started
    end
  end

  has_many :users, dependent: :restrict_with_exception
  has_many(
    :objets,
    foreign_key: :palissy_INSEE,
    primary_key: :code_insee,
    inverse_of: :commune,
    dependent: :restrict_with_exception
  )
  has_many :recensements, through: :objets
  has_many :past_dossiers, class_name: "Dossier", dependent: :nullify
  belongs_to :dossier, optional: true
  has_many :campaign_recipients, dependent: :destroy
  has_many :active_admin_comments, dependent: :destroy, as: :resource
  has_many :survey_votes, dependent: :nullify
  has_many :messages, dependent: :destroy

  scope :has_recensements_with_missing_photos, lambda {
    joins(:recensements).merge(Recensement.missing_photos).group(:id)
  }
  scope :recensements_photos_presence_in, lambda { |presence|
    presence ? all : has_recensements_with_missing_photos
  }
  scope :completed, -> { where(status: STATE_COMPLETED) }

  # these 2 scopes are a hack for ransack sorting on dossier_status from conservateurs/departements#show
  # from my understanding it should work out of the box with `dossier_status` but it doesn't ¯\_(ツ)_/¯
  # cf https://github.com/activerecord-hackery/ransack/blob/main/lib/ransack/adapters/active_record/context.rb#L211
  scope :sort_by_dossier_status_asc, -> { order("dossiers.status ASC") }
  scope :sort_by_dossier_status_desc, -> { order("dossiers.status DESC") }

  has_many(
    :edifices,
    foreign_key: :code_insee, primary_key: :code_insee,
    inverse_of: :commune, dependent: :restrict_with_exception
  )

  accepts_nested_attributes_for :dossier, :users

  STATUT_GLOBAL_SQL = %(CASE
    WHEN communes.status = 'inactive' THEN 'inactive'
    WHEN communes.status = 'started' THEN 'started'
    WHEN dossiers.status = 'submitted' AND recensements_analysed_count = 0 THEN 'submitted'
    WHEN dossiers.status = 'submitted' AND recensements_analysed_count > 0 THEN 'analyse_started'
    WHEN dossiers.status = 'accepted' then 'accepted'
  END).squish

  validate do |commune|
    next if commune.nom.blank? || commune.nom == commune.nom.strip

    errors.add(:nom, :invalid, message: "le nom contient des espaces en trop")
  end

  before_create { self.inbound_email_token ||= SecureRandom.hex(10) }

  def self.status_value_counts
    group(:status)
      .select("status, count(id) as communes_count")
      .to_h { [_1.status, _1.communes_count] }
  end

  def active?
    !inactive?
  end

  def can_complete?
    started? && all_objets_recensed?
  end

  def all_objets_recensed?
    objets.all?(&:recensement_completed?)
  end

  def to_s
    "#{nom} (#{code_insee})"
  end

  def highlighted_objet
    # used in campaigns
    Objet.select_best_objet_in_list(objets.where.not(palissy_TICO: nil).to_a)
  end

  def ongoing_campaign_recipient
    campaign_recipients.joins(:campaign).where(campaigns: { status: "ongoing" }).first
  end

  def can_be_campaign_recipient?
    inactive? && users.any? && objets.any?
  end

  def support_email(role:)
    parts = ["mairie", code_insee]
    parts << "conservateur" if role == :conservateur
    parts << inbound_email_token
    "#{parts.join('-')}@#{Rails.configuration.x.inbound_emails_domain}"
  end

  def aasm_before_start
    raise AASM::InvalidTransition if dossier.present?

    update!(dossier: Dossier.create!(commune: self))
  end

  def aasm_after_complete
    dossier.submit! unless dossier.submitted?
  end

  def aasm_after_return_to_started
    dossier.return_to_construction! unless dossier.construction?
  end

  # -------
  # RANSACK
  # -------

  def self.ransackable_attributes(_ = nil)
    %w[nom code_insee departement_code status objets_count en_peril_count disparus_count statut_global]
  end

  def self.ransackable_scopes(_ = nil) = [:recensements_photos_presence_in]
  def self.ransackable_associations(_ = nil) = %w[dossier dossiers objets]

  ransacker(:nom, type: :string) { Arel.sql("unaccent(nom)") }
end
