# frozen_string_literal: true

class PdfEmbedComponent < ViewComponent::Base
  attr_reader :attachment, :title

  DEFAULT_TITLE = "Fichier PDF"

  def initialize(attachment, title: nil)
    @attachment = attachment
    @title = title || DEFAULT_TITLE
    super
  end
end
