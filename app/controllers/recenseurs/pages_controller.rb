# frozen_string_literal: true

module Recenseurs
  class PagesController < BaseController
    before_action :skip_authorization

    def premiere_visite; end

    def after_premiere_visite
      current_recenseur.update(premiere_visite: false)
      redirect_to after_sign_in_path_for_recenseur(current_recenseur)
    end
  end
end
