# frozen_string_literal: true

class PresseController < ApplicationController
  def index
    @articles = ArticlePresse.load_all
  end

  def show
    raise ActionController::RoutingError, "Article inexistant" if ArticlePresse.all_ids.exclude? params[:id]

    @article = ArticlePresse.load_from_id(params[:id])
  end

  private

  def active_nav_links = ["À propos", "Presse", "On parle de nous"]
end
