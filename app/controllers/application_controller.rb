# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale
  before_action :set_sentry_context

  def render_turbo_stream_update(*args, **kwargs)
    render(turbo_stream: [turbo_stream.update(*args, **kwargs)])
  end

  protected

  def set_sentry_context
    if current_user
      set_sentry_current_user_context
    elsif current_conservateur
      set_sentry_current_conservateur_context
    end
  end

  def set_sentry_current_user_context
    Sentry.set_user(
      id: current_user.id,
      email: current_user.email,
      username: current_user.commune&.nom || current_user.email,
      ip_address: "{{auto}}",
      user_type: "user"
    )
  end

  def set_sentry_current_conservateur_context
    Sentry.set_user(
      id: current_conservateur.id,
      email: current_conservateur.email,
      username: current_conservateur.to_s,
      ip_address: "{{auto}}",
      user_type: "conservateur"
    )
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end

  def after_sign_in_path_for(resource)
    return commune_objets_path(resource.commune) if resource.is_a?(User)

    if resource.is_a?(Conservateur) && resource.departements.count == 1
      return conservateurs_departement_path(resource.departements.first)
    end

    return conservateurs_departements_path if resource.is_a?(Conservateur)

    super
  end
end
