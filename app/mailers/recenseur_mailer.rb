# frozen_string_literal: true

class RecenseurMailer < ApplicationMailer
  layout "recenseur_mailer"
  before_action :set_recenseur, except: :session_code
  before_action :skip_optouts

  default to: -> { email_address_with_name(@recenseur.email, @recenseur.nom) }

  def session_code
    @session_code = params[:session_code]
    @recenseur = @session_code.record
    skip_optouts
    @login_url = new_recenseur_session_code_url(email: @recenseur.email, session_code: @session_code.code)
    mail subject: "Code de connexion Collectif Objets - envoyé à #{I18n.l(Time.zone.now, format: :time_first)} "
  end

  private

  def set_recenseur = @recenseur = params.values_at(:recenseur)

  def skip_optouts
    throw :abort if @recenseur&.optout?
  end
end
