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
      params.require(:conservateur).permit(:messages_mail_notifications)
    end

    def success_notice
      case current_conservateur.messages_mail_notifications
      when true
        "Vous recevrez maintenant des emails pour les messages reçus !"
      when false
        "Vous ne recevrez plus d'emails pour les messages reçus !"
      end
    end
  end
end
