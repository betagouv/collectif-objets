class AddCampaignIdToDossiers < ActiveRecord::Migration[7.1]
  def change
    add_reference :dossiers, :campaign, foreign_key: true
    backfill unless reverting?
    RefreshAllCampaignStatsJob.set(wait: 5.minutes).perform_later unless reverting?
  end

  private

  def backfill
    say_with_time "Add campaign_id to dossiers" do
      Campaign.where(status: [:ongoing, :finished]).includes(:recipients).find_each do |campaign|
        commune_id = campaign.recipients.collect(&:commune_id)
        created_at = campaign.date_lancement..(campaign.date_fin + 1.year)
        Dossier.where(campaign_id: nil, commune_id:, created_at:).update_all(campaign_id: campaign.id)
      end
      # Return the number of dossiers updated
      Dossier.where.not(campaign_id: nil).count
    end
  end
end
