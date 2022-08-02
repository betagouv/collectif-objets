# frozen_string_literal: true

class CommuneStartError < StandardError
  def initialize(commune)
    super("commune #{commune} could not start: #{commune.errors.full_messages.join(', ')}")
  end
end

module Communes
  class CreateRecensementService
    RESULT = Struct.new(:success?, :recensement)

    def initialize(params:, objet:, user:)
      @params = params
      @objet = objet
      @user = user
    end

    def perform
      success = recensement.save
      post_create_actions if success
      RESULT.new(success, recensement)
    end

    protected

    attr_reader :params, :objet, :user

    delegate :commune, to: :objet

    def post_create_actions
      start_commune! if commune.inactive? || commune.enrolled?
      SendMattermostNotificationJob.perform_async(
        "recensement_created", { "recensement_id" => recensement.id }
      )
    end

    def start_commune!
      raise CommuneStartError, commune unless
        commune.start! &&
        commune.update!(dossier: recensement.dossier)

      TriggerSibContactEventJob.perform_async(commune.id, "started")
    end

    def recensement
      @recensement ||= Recensement.new(**params, **dossier_params, user:, objet:)
    end

    def dossier_params
      return { dossier_id: commune.dossier.id } if commune.dossier.present?

      { dossier_attributes: { commune_id: commune.id, status: "construction" } }
    end
  end
end
