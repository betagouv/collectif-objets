# frozen_string_literal: true

class RefreshCommuneRecensementRatioJob
  include Sidekiq::Job

  def perform(commune_id)
    @commune_id = commune_id
    communes.find_each do |commune|
      recensement_ratio = compute_recensement_ratio(commune)
      commune.update_columns(recensement_ratio:)
      Sidekiq.logger.info "updated ratio to #{recensement_ratio} for #{commune.nom}"
    end
  end

  protected

  def compute_recensement_ratio(commune)
    return nil if commune.objets.empty?

    (commune.recensements.count.to_f / commune.objets.count * 100).round
  end

  def communes
    if @commune_id == "all"
      Sidekiq.logger.info "loading communes..."
      Commune.all
    else
      Commune.where(id: @commune_id)
    end.includes(:objets, :recensements)
  end
end
