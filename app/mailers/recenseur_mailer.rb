# frozen_string_literal: true

class RecenseurMailer < ApplicationMailer
  layout "recenseur_mailer"
  before_action :set_recenseur, except: [:session_code, :access_revoked]
  before_action :skip_optouts

  default to: -> { email_address_with_name(@recenseur.email, @recenseur.nom) }

  def session_code
    @session_code = params[:session_code]
    @recenseur = @session_code.record
    skip_optouts
    @login_url = new_recenseur_session_code_url(email: @recenseur.email, session_code: @session_code.code)
    mail subject: "Code de connexion Collectif Objets - envoyé à #{I18n.l(Time.zone.now, format: :time_first)} "
  end

  def access_granted(preview: false)
    return false unless preview || @recenseur.notify_access_granted?

    @communes = @recenseur.new_communes
    # Pour simplifier l'accès, le mail inclut un code de connexion valide
    @session_code = @recenseur.session_code || @recenseur.create_session_code!
    mail subject: "Vous avez été autorisé à participer au recensement sur Collectif Objets"

    # On désactive la mise à jour pendant la prévisualisation
    @recenseur.new_accesses.update_all(notified: true) unless preview
  end

  def access_revoked
    @recenseur = Recenseur.new(**params)
    mail subject: "Votre accès à Collectif Objets a été supprimé"
  end

  private

  def set_recenseur = @recenseur = params[:recenseur]

  def skip_optouts
    false if @recenseur&.optout?
  end
end
