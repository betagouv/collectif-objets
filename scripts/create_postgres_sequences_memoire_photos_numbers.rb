# frozen_string_literal: true

# This is a hacky workaround : schema.rb does not preserve postgres sequences, so we manually upsert them
# We could use SQL schema file for a proper fix but we’d loose readability

ActiveRecord::Base.connection.execute(
  Departement::CODES.map { "CREATE SEQUENCE IF NOT EXISTS memoire_photos_number_#{_1}; " }.join
)
