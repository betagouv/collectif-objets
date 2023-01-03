# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def validate_email(user)
    @user = user
    @login_url = users_sign_in_with_token_url(
      login_token: @user.login_token
    )
    mail to: @user.email, subject: I18n.t("user_mailer.validate.subject")
  end

  def commune_completed_email
    @user = User.find(params[:user_id])
    @commune = Commune.find(params[:commune_id])
    set_login_url
    mail(
      to: @user.email,
      subject: I18n.t("user_mailer.commune_completed.subject", commune_nom: @commune.nom)
    )
  end

  def dossier_accepted_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    @user = @commune.users.first
    @conservateur = @dossier.conservateur || params[:conservateur]
    set_login_url
    dossier_mail(
      user: @commune.users.first,
      conservateur: @conservateur,
      subject: I18n.t("user_mailer.dossier_accepted.subject", commune_nom: @commune.nom)
    )
  end

  def dossier_rejected_email
    @dossier = params[:dossier]
    @commune = @dossier.commune
    @conservateur = @dossier.conservateur
    @user = @commune.users.first
    set_login_url
    dossier_mail(
      user: @user,
      conservateur: @conservateur,
      subject: I18n.t("user_mailer.dossier_rejected.subject", commune_nom: @commune.nom)
    )
  end

  def dossier_auto_submitted_email
    @user = params[:user]
    @commune = params[:commune]
    set_login_url
    mail(
      to: @user.email,
      subject: I18n.t("user_mailer.dossier_auto_submitted.subject", commune_nom: @commune.nom)
    )
  end

  protected

  def set_login_url
    @login_url = \
      if @user.magic_token.present?
        magic_authentication_url("magic-token" => @user.magic_token)
      else
        new_user_session_url
      end
  end

  def dossier_mail(user:, conservateur:, subject:)
    mail(
      to: user.email,
      subject:,
      from: email_address_with_name("collectifobjets@beta.gouv.fr", conservateur.to_s),
      reply_to: conservateur.email
    )
  end
end
