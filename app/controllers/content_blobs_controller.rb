# frozen_string_literal: true

class ContentBlobsController < ApplicationController
  def show
    raise ArgumentError if ContentBlob.all_ids.exclude? params[:id]

    @content_blob = ContentBlob.load_from_id(params[:id])
  end

  def active_nav_links = %w[Documentation]
end
