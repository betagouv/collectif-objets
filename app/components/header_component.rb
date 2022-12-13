# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  renders_one :navbar
  renders_one :tools
  renders_one :menu

  attr_reader :notice, :alert

  def initialize(notice: nil, alert: nil)
    @notice = notice
    @alert = alert
    super
  end
end
