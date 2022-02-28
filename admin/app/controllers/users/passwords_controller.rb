# frozen_string_literal: true

module Users
  class PasswordsController < Devise::PasswordsController

    # POST /resource/password
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        redirect_to root_path, notice: "You should receive a mail soon"
      else
        respond_with(resource)
      end
    end
  end
end
