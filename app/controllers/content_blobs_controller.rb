# frozen_string_literal: true

class ContentBlobsController < ApplicationController
  def show
    raise ActiveRecord::RecordNotFound if ContentBlob.ids.exclude? params[:id]

    @content_blob = ContentBlob.find(params[:id])
  end

  def active_nav_links = ["Aide en ligne"]
end
