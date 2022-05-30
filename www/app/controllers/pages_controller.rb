# frozen_string_literal: true

class PagesController < ApplicationController
  def home; end
  def aide; end
  def stats; end

  def guide
    page = params[:page]&.to_i
    page_query = "#page=#{page}" if page&.positive?

    @guide_url = "https://fichiers.collectif-objets.beta.gouv.fr/Guidederecensement.pdf#{page_query}"
  end

  def confirmation_inscription; end

  def cgu; end
  def mentions_legales; end
  def confidentialite; end
end
