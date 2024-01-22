# frozen_string_literal: true

module Synchronizer
  module Communes
    class Revision
      attr_reader :row
      attr_accessor :commune

      def initialize(row, commune: nil)
        @row = row
        @commune = commune
      end

      def synchronize
        # TODO: we should actually do something with these communes that became annexes / déléguées
        return if !mairie? || mairie_annexe? || !commune

        upsert_commune
        upsert_user
      end

      def code_insee = row["code_insee_commune"]
      def nom = row["nom"].gsub(/^Mairie - ?/, "").strip
      def email = row["adresse_courriel"]

      def departement_code
        code_insee.starts_with?("97") ? code_insee[0..2] : code_insee[0..1]
      end

      def phone_number
        return nil if row["telephone"].blank?

        parsed = JSON.parse(row["telephone"]).first["valeur"]
        return nil if parsed.blank? || parsed == "f"

        parsed
      end

      def type_service_local
        JSON.parse(row["pivot"] || "[]")&.first&.dig("type_service_local")
      rescue JSON::ParserError
        Rails.logger.error "error when parsing pivot #{row} "
      end

      def mairie?
        code_insee.present? && type_service_local == "mairie"
      end

      def mairie_annexe?
        (mairie? &&
          nom.match(/Mairi(e|é) (déléguée|annexe)/i)) ||
          nom.match(/ - (annexe|antenne) /i) ||
          nom.match(/bureau annexe/i)
      end

      def attributes
        %w[code_insee nom email departement_code phone_number type_service_local].to_h { [_1, send(_1)] }
      end

      def to_s
        "Synchronizer::Communes::Revision #{attributes.values.compact.join(',')}"
      end

      private

      def upsert_commune
        commune.assign_attributes(departement_code:, nom:, phone_number:)
        return unless commune.changed?

        Rails.logger.info "saving changes to commune #{code_insee} #{commune.changes}"
        commune.save
        return unless commune.errors.any?

        Rails.logger.warn "error when saving commune #{self}"
        raise commune.errors.full_messages.join(", ")
      end

      def upsert_user
        # TODO: this actually never updates but only inserts
        return if email.blank? || commune.users.any?

        user = User.create(
          email:,
          magic_token: SecureRandom.hex(10),
          commune_id: commune.id
        )
        return unless user.errors.any?

        Rails.logger.info "error when saving user for revision #{self} : #{user.errors.full_messages.join}"
      end
    end
  end
end
