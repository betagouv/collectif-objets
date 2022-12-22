# frozen_string_literal: true

class SurveyVote < ApplicationRecord
  belongs_to :commune, optional: true

  CAMPAIGN_INACTIVE_REASONS = {
    trop_court: "Les délais étaient trop courts",
    collectif_objets_inconnu: "Je ne connais pas Collectif Objets",
    autres_priorites: "J'ai d'autres priorités",
    pas_acces: "Je n'ai pas accès aux objets (église fermée pour travaux...)",
    pas_interesse: "Ça ne m'intéresse pas",
    autre: "Autre"
  }.freeze

  validates :survey, inclusion: { in: %w[campaign_inactive] }
  validates :commune_id, uniqueness: { scope: :survey }
  validates :reason, inclusion: { in: CAMPAIGN_INACTIVE_REASONS.keys.map(&:to_s) }
end
