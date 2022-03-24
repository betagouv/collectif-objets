# frozen_string_literal: true

module Communes
  class CompletionsController < BaseController
    before_action :restrict_not_started, :restrict_already_completed, except: [:show]
    before_action :restrict_completed, only: [:show]

    def new
      @objets = @commune.objets.includes(:recensements)
    end

    def show
      @objets = @commune.objets.includes(:recensements)
    end

    def create
      if @commune.update(commune_params)
        TriggerSibContactEventJob.perform_async(@commune.id, "completed")
        SendMattermostNotificationJob.perform_async("commune_completed", { "commune_id" => @commune.id })
        redirect_to commune_objets_path(@commune), notice: "Le recensement de votre commune est terminé !"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def restrict_not_started
      return true if @commune.enrolled_or_started?

      redirect_to root_path, alert: "Le recensement de votre commune n'a pas commencé !"
    end

    def restrict_already_completed
      return true unless @commune.completed?

      redirect_to root_path, alert: "Le recensement de votre commune est déjà terminé !"
    end

    def restrict_completed
      return true if @commune.completed?

      redirect_to root_path, alert: "Le recensement de votre commune n'est pas encore terminé !"
    end

    def commune_params
      params.require(:commune).permit(:notes_from_completion).to_h
          .deep_merge(status: Commune::STATUS_COMPLETED, completed_at: Time.zone.now)
    end
  end
end
