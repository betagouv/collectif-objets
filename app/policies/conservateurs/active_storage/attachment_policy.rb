# frozen_string_literal: true

module Conservateurs
  module ActiveStorage
    class AttachmentPolicy < BasePolicy
      alias attachment record

      def update?
        attachment.record.is_a?(Recensement) &&
          conservateur.departements.include?(recensement.departement) &&
          recensement.commune.completed? &&
          recensement.dossier.submitted? &&
          !impersonating?
      end

      alias destroy? update?
      alias create? update?

      private

      def recensement = attachment.record
    end
  end
end
