# frozen_string_literal: true

require "active_support/concern"

module Recensements
  module CompleteConcern
    extend ActiveSupport::Concern

    def complete
      self.status = "completed"
      assign_attributes(dossier_params)
      success = save
      post_create_actions if success
      success
    end

    private

    def post_create_actions
      start_commune! if commune.inactive?
      SendMattermostNotificationJob.perform_async("recensement_created", { "recensement_id" => id })
    end

    def start_commune!
      raise CommuneStartError, commune unless commune.start! && commune.update!(dossier:)
    end

    def dossier_params
      return { dossier_id: commune.dossier.id } if commune.dossier.present?

      { dossier_attributes: { commune_id: commune.id, status: "construction" } }
    end
  end

  class CommuneStartError < StandardError
    def initialize(commune)
      super("commune #{commune} could not start: #{commune.errors.full_messages.join(', ')}")
    end
  end
end
