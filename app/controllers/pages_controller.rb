# frozen_string_literal: true

class PagesController < ApplicationController
  PDFS = { "guide" => "Guidederecensement" }.freeze
  STATIC_FILES_HOST = "fichiers.collectif-objets.beta.gouv.fr"

  def home
    @stats = Rails.cache.fetch("homepage_stats", expires_in: 24.hours) do
      { recensements: Objet.where.associated(:recensements).count, communes: Commune.completed.count }
    end
  end

  def admin
    @active_nav_links = ["Administration"]
    redirect_to new_admin_user_session_path, alert: "Connectez-vous en tant qu'admin" unless admin_user_signed_in?
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

  def campaigns_ics
    campaigns = Campaign.where.not(status: :draft).includes(:departement)
    ics = Co::Campaigns::Ics.new(campaigns)
    render plain: ics.to_ical, content_type: "text/calendar"
  end

  def aide
    @active_nav_links = ["Aide", "Aide en ligne"]
  end

  def stats
    @active_nav_links = ["À propos", "Statistiques"]
  end

  def accueil_conservateurs
    @active_nav_links = ["Je suis conservateur"]
  end

  attr_reader :active_nav_links
end
