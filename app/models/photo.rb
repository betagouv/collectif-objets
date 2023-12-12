# frozen_string_literal: true

class Photo
  extend Forwardable
  attr_reader :url, :description, :credit, :recensement, :attachment

  def initialize(url:, description: nil, credit: nil, thumb_url: nil, recensement: nil, attachment: nil)
    @url = url
    @thumb_url = thumb_url
    @description = description
    @credit = credit
    @recensement = recensement
    @attachment = attachment
  end

  def self.from_attachment(attachment)
    new(
      url: Rails.application.routes.url_helpers.url_for(attachment),
      thumb_url: Rails.application.routes.url_helpers.url_for(attachment.variant(:medium)),
      credit: "© Licence ouverte",
      recensement: attachment.record,
      attachment:
    )
  end

  def thumb_url = @thumb_url || @url

  def alt = [description, credit].map(&:presence).compact.join(" - ")

  def_delegators :@recensement, :objet
  def_delegators :@attachment, :blob_id
end
