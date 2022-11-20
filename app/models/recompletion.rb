# frozen_string_literal: true

class Recompletion
  attr_reader :dossier

  delegate :commune, :notes_commune, to: :dossier

  def initialize(dossier:)
    @dossier = dossier
  end

  def create!(notes_commune:)
    return false unless dossier.submit!(notes_commune:)

    ConservateurMailer.with(dossier: @dossier).commune_recompleted_email.deliver_later
    true
  end
end
