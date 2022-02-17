# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale
  before_action :set_sentry_context

  protected

  def set_sentry_context
    return true unless current_user

    Sentry.set_user(
      id: current_user.id,
      email: current_user.email,
      username: current_user.commune&.nom || current_user.email,
      ip: "{{auto}}"
    )
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end
end
