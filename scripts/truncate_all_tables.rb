# frozen_string_literal: true

raise if Rails.configuration.x.environment_specific_name == "production"

ActiveRecord::Base.connection.truncate_tables(
  *%i[
    active_admin_comments active_storage_attachments active_storage_blobs
    active_storage_variant_records admin_users
    campaign_emails campaign_recipients campaigns communes conservateur_roles
    conservateurs departements dossiers objet_overrides objets recensements users
  ]
)
