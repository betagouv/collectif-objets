# frozen_string_literal: true

class MailPreviewsController < ApplicationController
  before_action :set_mailer_preview, :set_mail

  def index
    @previews = ActionMailer::Preview.all
  end

  private

  def set_mailer_preview
    return if params[:mailer_name].blank?

    @mailer_preview = ActionMailer::Preview.find(params[:mailer_name].underscore)

    return if @mailer_preview.email_exists?(params[:mail_name])

    raise AbstractController::ActionNotFound, "Email '#{@email_action}' not found in #{@mailer_preview.name}"
  end

  def set_mail
    return if @mailer_preview.blank? || params[:mail_name].blank?

    @mail_name = params[:mail_name]
    @mail = @mailer_preview.call(@mail_name)
  end
end
