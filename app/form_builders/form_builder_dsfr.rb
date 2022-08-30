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
    options[:class] ||= ""
    options[:class] += " fr-input"
    super(method, options)
  end

  def select(method, choices, options = {}, html_options = {})
    html_options = html_options.with_indifferent_access
    html_options[:class] ||= ""
    html_options[:class] += " fr-select"
    super(method, choices, options, html_options)
  end

  def submit(value, options = {})
    options = options.with_indifferent_access
    options[:class] ||= ""
    options[:class] += " fr-btn"
    super(value, options)
  end
end
