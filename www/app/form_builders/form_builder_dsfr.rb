# frozen_string_literal: true

class FormBuilderDsfr < ActionView::Helpers::FormBuilder
  def label(method, name = nil, options = {})
    super(method, name, options.merge(class: "#{options.fetch(:class, '')} fr-label"))
  end

  def text_field(method, options = {})
    super(method, options.merge(class: "fr-input"))
  end

  def email_field(method, options = {})
    super(method, options.merge(class: "fr-input"))
  end

  def password_field(method, options = {})
    super(method, options.merge(class: "fr-input"))
  end

  def text_area(method, options = {})
    super(method, options.merge(class: "fr-input"))
  end

  def select(method, choices, options = {}, html_options = {})
    super(method, choices, options, html_options.merge(class: "fr-select"))
  end

  def submit(value, options = {})
    super(value, options.merge(class: "fr-btn"))
  end
end
