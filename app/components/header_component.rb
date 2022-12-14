# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  renders_one :navbar
  renders_many :tool_links, lambda { |text, path, icon:, **kwargs|
    link_to text, path, class: "fr-link #{icon ? "fr-icon-#{icon}-line" : ''}", **kwargs
  }
  renders_one :menu
  renders_one :search

  attr_reader :notice, :alert

  def initialize(notice: nil, alert: nil)
    @notice = notice
    @alert = alert
    super
  end
end
