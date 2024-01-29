# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  impersonates :user
  impersonates :conservateur

  before_action :init_banners
  before_action :set_locale
  before_action :set_sentry_context

  def render_turbo_stream_update(*, **)
    render(turbo_stream: [turbo_stream.update(*, **)])
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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
    return params[:after_sign_in_path] if params[:after_sign_in_path].present?

    send("after_sign_in_path_for_#{resource.class.name.downcase}", resource)
  end

  def after_sign_in_path_for_user(user)
    if user.commune.recensements.completed.empty?
      commune_premiere_visite_path(user.commune)
    else
      commune_objets_path(user.commune)
    end
  end

  def after_sign_in_path_for_conservateur(conservateur)
    return conservateurs_departement_path(conservateur.departements.first) if conservateur.departements.count == 1

    conservateurs_departements_path
  end

  def after_sign_in_path_for_adminuser(_admin_user)
    admin_path
  end

  def user_not_authorized(exception)
    message = "Vous n'avez pas le droit de faire cette action"
    message += " : #{exception.message}" if Rails.env.development?
    flash[:alert] = message
    redirect_back(fallback_location: root_path)
  end

  helper_method :active_nav_links
  def active_nav_links = []

  def init_banners
    @banners = []
    @banners << :environment if %w[development staging].include?(Rails.configuration.x.environment_specific_name)
    @banners << :user_impersonate if current_user.present? && current_user != true_user
    @banners << :conservateur_impersonate if current_conservateur.present? && current_conservateur != true_conservateur
  end
end
