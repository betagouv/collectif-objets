# frozen_string_literal: true

module Galerie
  class LightboxComponent < ApplicationComponent
    include ApplicationHelper

    delegate(
      :photos,
      :current_photo_id,
      :close_path,
      :turbo_frame,
      :count,
      :path_without_query,
      :actions,
      :current_photo,
      :previous_photo,
      :next_photo,
      :current_index,
      to: :@galerie
    )

    def initialize(galerie)
      super
      @galerie = galerie
    end
  end
end
