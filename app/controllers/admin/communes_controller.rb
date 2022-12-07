# frozen_string_literal: true

module Admin
  class CommunesController < BaseController
    def index
      @pagy, @communes = pagy(
        Commune.all.include_objets_count, items: 20
      )
    end
  end
end
