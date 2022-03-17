# frozen_string_literal: true

module Communes
  class EnrollmentsController < BaseController
    before_action :restrict_already_enrolled

    def new; end

    def create
      if params[:confirmation].blank?
        @commune.errors.add(:base, "Veuillez cocher la case de confirmation")
        return render :new, status: :unprocessable_entity
      end

      if @commune.update(status: Commune::STATUS_ENROLLED, enrolled_at: Time.zone.now)
        enqueue_jobs
        redirect_to commune_objets_path(@commune), notice: "Votre commune a bien été inscrite !"
      else
        render :new, status: :unprocessable_entity
      end
    end

    protected

    def restrict_already_enrolled
      return true if @commune.status.nil?

      redirect_to root_path, alert: "Votre commune est déjà inscrite"
    end

    def enqueue_jobs
      TriggerSibContactEventJob.perform_async(@commune.id, "enrolled")
      SendMattermostNotificationJob.perform_async("commune_enrolled", { "commune_id" => @commune.id })
    end
  end
end
