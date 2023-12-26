# frozen_string_literal: true

class ApplicationMailerPreview < ActionMailer::Preview
  private

  def build(*, **)
    FactoryBot.build(*, **).tap(&:readonly!)
  end

  def build_list(*, **)
    list = FactoryBot.build_list(*, **)
    list.each(&:readonly!)
    list
  end
end
