# frozen_string_literal: true

class RefreshRecensementPhotosCountJob
  include Sidekiq::Job

  def perform
    Recensement.where.missing(:photos_attachments).update_all(photos_count: 0)
    Recensement.joins(:photos_attachments).includes(:photos_attachments).each do |recensement|
      recensement.update_columns(photos_count: recensement.photos_attachments.length)
    end
  end
end
