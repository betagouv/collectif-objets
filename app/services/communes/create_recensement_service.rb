# frozen_string_literal: true

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
      if commune.may_start?
        commune.start!
        TriggerSibContactEventJob.perform_async(commune.id, "started")
      end
      SendMattermostNotificationJob.perform_async(
        "recensement_created", { "recensement_id" => recensement.id }
      )
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
