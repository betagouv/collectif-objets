# frozen_string_literal: true

module Admin
  module Exports
    class PopController < BaseController
      def index
        @departements = Departement
          .order(:code)
          .includes(:dossiers)
          .where.not(dossiers: { accepted_at: nil })
          .where(recensements: Recensement.absent_or_recensable)
          .includes(recensements: %i[photos_attachments objet])
      end

      private

      def active_nav_links
        ["Administration"]
      end
    end
  end
end
