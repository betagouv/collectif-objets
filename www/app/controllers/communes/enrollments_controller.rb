# frozen_string_literal: true

module Communes
  class EnrollmentsController < BaseController
    before_action :set_user, :restrict_already_enrolled

    def new; end

    def create
      if @user.update(user_params)
        redirect_to commune_objets_path(@commune), notice: "Votre commune a bien été inscrite !"
      else
        render :new
      end
    end

    protected

    def set_user
      @user = current_user
      @user.email_personal ||= current_user.email
    end

    def restrict_already_enrolled
      return true if @commune.status.nil?

      redirect_to root_path, alert: "Votre commune est déjà inscrite"
    end

    def user_params
      params.require(:user).permit(
        :nom, :job_title, :email_personal, :phone_number,
        commune_attributes: %i[notes_from_enrollment id]
      ).to_h.deep_merge(
        commune_attributes: {
          status: Commune::STATUS_ENROLLED,
          enrolled_at: Time.zone.now
        }
      )
    end
  end
end
