# frozen_string_literal: true

class ApplicationMailerPreview < ActionMailer::Preview
  private

  def build(*args, **kwargs)
    FactoryBot.build(*args, **kwargs).tap(&:readonly!)
  end
end
