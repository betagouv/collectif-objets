# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale

  def set_locale
    I18n.locale = I18n.default_locale
  end
end
