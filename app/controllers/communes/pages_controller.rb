# frozen_string_literal: true

module Communes
  class PagesController < BaseController
    before_action :skip_authorization

    def premiere_visite; end
  end
end
