# frozen_string_literal: true

class PresseController < ApplicationController
  def index
    @articles = ArticlePresse.all
  end

  def show
    @article = ArticlePresse.find(params[:id])
  end

  private

  def active_nav_links = ["À propos", "Presse", "On parle de nous"]
end
