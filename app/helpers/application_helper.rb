# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def head_title
    if content_for(:head_title).present?
      "#{content_for(:head_title)} · Collectif Objets"
    else
      "Collectif Objets"
    end
  end

  def badge(color = "", **html_opts)
    html_opts[:class] ||= ""
    html_opts[:class] += " fr-badge fr-badge--sm fr-badge--#{color}"
    content_tag("p", yield, **html_opts)
  end

  def link_to_button(content, path, **kwargs)
    content_tag("form", method: "GET", action: path) do
      content_tag("button", **kwargs) { content }
    end
  end

  def blockquote(content, html_options = {})
    html_options = html_options.with_indifferent_access
    html_options[:class] ||= ""
    html_options[:class] += " fr-callout__text co-blockquote fr-text--alt"
    content_tag("blockquote", content, **html_options)
  end

  def t_fallback(key)
    return I18n.t(key) if I18n.exists?(key)

    scope = key.split(".").tap(&:pop).join(".")
    I18n.t("#{scope}.other")
  end
end
