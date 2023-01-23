# frozen_string_literal: true

class ApplicationMailerPreview < ActionMailer::Preview
  private

  def build(*args, **kwargs)
    FactoryBot.build(*args, **kwargs).tap(&:readonly!)
  end

  def build_list(*args, **kwargs)
    list = FactoryBot.build_list(*args, **kwargs)
    list.each(&:readonly!)
    list
  end
end
