# frozen_string_literal: true

module Galerie
  class FrameComponent < ViewComponent::Base
    include ApplicationHelper
    include Turbo::FramesHelper

    attr_reader :photos, :title, :turbo_frame, :current_photo_id, :path_without_query, :display_actions

    delegate :count, to: :photos

    def initialize(photos:, title:, turbo_frame:, current_photo_id:, path_without_query:, display_actions: false)
      super
      @photos = photos
      @title = title
      @turbo_frame = turbo_frame
      @current_photo_id = current_photo_id
      @path_without_query = path_without_query
      @display_actions = display_actions
    end

    def lightbox_photo_path(photo_id)
      "#{path_without_query}?#{current_photo_id_param_name}=#{photo_id}"
    end

    def close_path = path_without_query
    def current_photo_id_param_name = "#{turbo_frame}_photo_id"

    def call
      turbo_frame_tag turbo_frame do
        if current_photo_id
          render Galerie::LightboxComponent.new(self)
        else
          render Galerie::MiniaturesComponent.new(self)
        end
      end
    end
  end
end
