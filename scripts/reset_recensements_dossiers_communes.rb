# frozen_string_literal: true

raise if Rails.configuration.x.environment_specific_name == "production"

Dossier.delete_all
Recensement.delete_all
Commune.update_all(status: :inactive, recensement_ratio: 0, started_at: nil)
