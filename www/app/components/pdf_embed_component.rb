# frozen_string_literal: true

class PdfEmbedComponent < ViewComponent::Base
  attr_reader :attachment, :title

  def initialize(attachment, title: nil)
    @attachment = attachment
    @title = title || "Fichier PDF"
    super
  end

  def download_filename
    "generated.pdf"
  end
end
