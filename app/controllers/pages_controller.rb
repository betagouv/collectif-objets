# frozen_string_literal: true

class PagesController < ApplicationController
  PDFS = {
    "guide" => "Guidederecensement",
    "fiche_nuisibles" => "fiche_nuisibles",
    "fiche_securisation" => "fiche_securisation",
    "fiche_vol" => "fiche_vol"
  }.freeze
  STATIC_FILES_HOST = "fichiers.collectif-objets.beta.gouv.fr"

  def home
    @stats = Rails.cache.fetch("homepage_stats", expires_in: 24.hours) do
      { recensements: Recensement.count, communes: Commune.completed.count }
    end
  end

  def aide; end
  def stats; end
  def presse; end

  def admin
    redirect_to new_admin_user_session_path, alert: "Connectez-vous en tant qu'admin" if current_admin_user.nil?
  end

  def guide
    params[:pdf] = "guide"
    pdf_embed
    render "pdf_embed"
  end

  def pdf_embed
    @pdf_name = params[:pdf]
    raise unless PDFS.keys.include?(@pdf_name)

    @breadcrumbs = @pdf_name.starts_with?("fiche") ? [["Fiches", fiches_url]] : []
    @page = params[:page]&.to_i if params[:page]&.to_i&.positive?
  end

  def pdf_download
    filename = PDFS[params[:pdf]]
    raise if filename.blank?

    pdf_body = Rails.cache.fetch("pdfs/1.0/#{filename}.pdf", expires_in: 2.days) do
      url = "https://#{STATIC_FILES_HOST}/#{filename}.pdf"
      res = Net::HTTP.get_response(URI.parse(url))
      raise unless res.code.starts_with?("2")

      res.body
    end

    send_data(pdf_body, content_type: "application/pdf", filename:, disposition: :inline)
  end

  def cgu; end
  def mentions_legales; end
  def confidentialite; end
  def fiches; end
end
