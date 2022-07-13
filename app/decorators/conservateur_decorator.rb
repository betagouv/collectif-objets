# frozen_string_literal: true

class ConservateurDecorator < Draper::Decorator
  delegate_all

  # rubocop:disable Rails/OutputSafety
  def departements_with_names
    departements.map { Co::Departements.number_and_name(_1) }.join("<br />").html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
