# frozen_string_literal: true

module Conservateurs
  class CreateRecensementService
    attr_reader :success
    alias success? success

    def initialize(params:, objet:, conservateur:)
      @params = params
      @objet = objet
      @conservateur = conservateur
    end

    def perform
      @success = recensement.save
      return unless @success

      SendMattermostNotificationJob
        .perform_async("recensement_created", { "recensement_id" => recensement.id })
    end

    def recensement
      @recensement ||= Recensement.new(**params, **dossier_params, conservateur:, objet:)
    end

    protected

    attr_reader :params, :objet, :conservateur

    delegate :edifice, :commune, to: :objet

    def dossier_params
      return { dossier_id: edifice.current_dossier.id } if edifice.current_dossier?

      { dossier_attributes: new_dossier_attributes }
    end

    def new_dossier_attributes
      {
        edifice_id: edifice.id,
        commune_id: commune.id,
        status: "construction",
        author_role: "conservateur",
        conservateur_id: @conservateur.id
      }
    end
  end
end
