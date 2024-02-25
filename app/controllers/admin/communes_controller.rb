# frozen_string_literal: true

module Admin
  class CommunesController < BaseController
    def index
      @ransack = Commune.include_statut_global.ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @communes = pagy(
        @ransack.result.include_objets_count, items: 20
      )
    end

    def show
      @commune = Commune.find(params[:id])
      @messages = Message.where(commune: @commune).order(created_at: :asc)
    end

    def send_test_email
      commune = Commune.find(params[:commune_id])
      CampaignV1Mailer.with(
        commune:,
        user: commune.users.first,
        campaign_recipient: CampaignRecipient.new(unsubscribe_token: "g8fy3hcu3498").tap(&:readonly!),
        campaign: Campaign.new(
          departement: commune.departement,
          date_lancement: Time.zone.today,
          date_relance1: Time.zone.today.next_week(:monday),
          date_relance2: (Time.zone.today + 7.days).next_week(:monday),
          date_relance3: (Time.zone.today + 14.days).next_week(:monday),
          date_fin: (Time.zone.today + 21.days).next_week(:monday),
          sender_name: "Jeanine Sloop",
          nom_drac: "Grand Est",
          signature:
            "Jeanne Dupont\n\nConservatrice en charge des monuments historiques\n" \
            "DRAC Rhône-Alpes, Châlons-sur-Saone, 10 rue de la république"
        ).tap(&:readonly!)
      ).lancement_email.deliver_now
      redirect_to admin_commune_path(commune), notice: "Email envoyé"
    end

    private

    def active_nav_links = %w[Communes]
  end
end
