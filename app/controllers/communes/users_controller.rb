# frozen_string_literal: true

module Communes
  class UsersController < BaseController
    def update
      authorize(current_user)
      if current_user.update(user_params)
        redirect_to edit_user_registration_path, notice: success_notice
      else
        render "users/registrations/edit", status: :unprocessable_content
      end
    end

    private

    def user_params
      params.require(:user).permit(:messages_mail_notifications)
    end

    def success_notice
      case current_user.messages_mail_notifications
      when true
        "Vous recevrez maintenant des emails pour les messages reçus !"
      when false
        "Vous ne recevrez plus d'emails pour les messages reçus !"
      end
    end
  end
end
