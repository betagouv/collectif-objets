# frozen_string_literal: true

module Conservateurs
  class ConservateursController < BaseController
    def update
      authorize(current_conservateur)
      if current_conservateur.update(conservateur_params)
        redirect_to edit_conservateur_registration_path, notice: success_notice
      else
        render "users/registrations/edit", status: :unprocessable_entity
      end
    end

    private

    def conservateur_params
      params.require(:conservateur).permit(:messages_mail_notifications, :send_recap)
    end

    def success_notice
      case [current_conservateur.messages_mail_notifications, current_conservateur.send_recap]
      when [true, true]
        "Vous recevrez maintenant un email pour chaque message,
          et un récapitulatif d'activité chaque semaine."
      when [true, false]
        "Vous recevrez maintenant un email pour chaque message,
          mais pas de récapitulatifs d'activité."
      when [false, true]
        "Vous recevrez maintenant les récapitulatifs d'activité chaque semaine,
          mais ne serez pas notifié des nouveaux messages."
      when [false, false]
        "Vous ne recevrez plus d'emails depuis la plateforme."
      end
    end
  end
end
