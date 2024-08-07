# frozen_string_literal: true

module Admin
  class MailPreviewsController < BaseController
    before_action :set_mailers

    # Temporarily allow inline styles when previewing emails
    content_security_policy(only: :show) do |policy|
      policy.style_src :self, :https, :unsafe_inline
    end

    def index; end

    def show
      @mailer = ActionMailer::Preview.find(params[:mailer].underscore)
      @email = params[:email]
      unless @mailer&.email_exists?(@email)
        raise AbstractController::ActionNotFound,
              "L'email '#{@email}' n'est pas disponible dans le mailer '#{@mailer&.name || params[:mailer]}'"
      end
      @mail = @mailer.call(@email)
    end

    private

    def set_mailers
      @mailers = ActionMailer::Preview.all.reject { |mailer| mailer.emails.empty? }
    end
  end
end
