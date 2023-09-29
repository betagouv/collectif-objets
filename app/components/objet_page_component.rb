# frozen_string_literal: true

class ObjetPageComponent < ViewComponent::Base
  include ObjetHelper
  attr_reader :objet

  renders_one :cta

  def initialize(objet:, avec_lien_signalement: false)
    @objet = objet
    @avec_lien_signalement = avec_lien_signalement
    super
  end
end
