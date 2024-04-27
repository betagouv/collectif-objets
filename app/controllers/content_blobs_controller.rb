# frozen_string_literal: true

class ContentBlobsController < ApplicationController
  def show
    @content_blob = ContentBlob.find(params[:id])
  end

  def active_nav_links = ["Aide en ligne"]
end
