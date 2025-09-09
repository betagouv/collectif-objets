# frozen_string_literal: true

class PasswordInputComponent < ApplicationComponent
  attr_reader :name, :autocomplete, :autofocus, :label, :hint

  def initialize(name:, autocomplete: nil, autofocus: false, label: "Mot de passe", hint: true)
    @name = name
    @autocomplete = autocomplete
    @autofocus = autofocus
    @label = label
    @hint = hint
    super
  end

  def input_id
    name.parameterize
  end
end
