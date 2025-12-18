# frozen_string_literal: true

module Admin
  class CommunesController < BaseController
    def index
      @ransack = Commune.preload(:users).include_statut_global.ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @communes = pagy(
        @ransack.result, items: 20
      )
    end

    def show
      @commune = Commune.includes(
        edifices: :objets,
        archived_dossiers: { recensements: { objet: [], photos_attachments: :blob } }
      ).find(params[:id])
      @messages = Message
        .includes(:author, :inbound_email, files_attachments: :blob)
        .where(commune: @commune)
        .order(created_at: :asc)
    end

    def session_code
      @commune = Commune.find(params[:id])
      user = @commune.users.first
      @session_code = user.session_code || user.create_session_code
      redirect_to [:admin, @commune]
    end

    private

    def active_nav_links = %w[Communes]
  end
end
