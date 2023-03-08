# frozen_string_literal: true

class CommuneStartError < StandardError
  def initialize(commune)
    super("commune #{commune} could not start: #{commune.errors.full_messages.join(', ')}")
  end
end

module Communes
  class CreateRecensementService
    def initialize(recensement)
      @recensement = recensement
    end

    def perform
      recensement.status = "completed"
      recensement.assign_attributes(dossier_params)
      success = recensement.save
      post_create_actions if success
      success
    end

    protected

    attr_reader :recensement

    delegate :commune, to: :recensement

    def post_create_actions
      start_commune! if commune.inactive?
      SendMattermostNotificationJob.perform_async("recensement_created", { "recensement_id" => recensement.id })
    end

    def start_commune!
      raise CommuneStartError, commune unless
        commune.start! &&
        commune.update!(dossier: recensement.dossier)
    end

    def dossier_params
      return { dossier_id: commune.dossier.id } if commune.dossier.present?

      { dossier_attributes: { commune_id: commune.id, status: "construction" } }
    end
  end
end
