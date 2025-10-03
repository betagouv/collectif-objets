# frozen_string_literal: true

class PagesController < ApplicationController
  STATIC_FILES_HOST = "fichiers.collectif-objets.beta.gouv.fr"

  before_action :render_markdown, only: [
    :conditions,
    :confidentialite,
    :mentions_legales,
    :declaration_accessibilite,
    :schema_pluriannuel_accessibilite
  ]

  def home
    @stats = Rails.cache.fetch("homepage_stats", expires_in: 24.hours) do
      { recensements: Recensement.select(:objet_id).distinct.count, communes: Commune.completed.count }
    end
  end

  def guide
    respond_to do |format|
      format.html
      format.pdf do
        filename = "Guidederecensement"
        pdf_body = Rails.cache.fetch("pdfs/1.0/#{filename}.pdf", expires_in: 2.days) do
          url = "https://#{STATIC_FILES_HOST}/#{filename}.pdf"
          res = Net::HTTP.get_response(URI.parse(url))
          raise unless res.code.starts_with?("2")

          res.body
        end

        send_data(pdf_body, content_type: "application/pdf", filename:, disposition: :inline)
      end
    end
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

  def conditions; end
  def confidentialite; end
  def mentions_legales; end
  def declaration_accessibilite; end
  def schema_pluriannuel_accessibilite; end

  attr_reader :active_nav_links

  private

  def render_markdown
    @content_blob = ContentBlob.find(action_name)
    render "content_blobs/show"
  end
end
