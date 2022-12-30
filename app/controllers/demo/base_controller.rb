# frozen_string_literal: true

module Demo
  class BaseController < ApplicationController
    include Co::DemoFactoryBot
    layout "demo"

    def policy(*, **)
      Struct.new(:new?).new(true)
    end
    helper_method :policy
  end
end
