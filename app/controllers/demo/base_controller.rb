# frozen_string_literal: true

module Demo
  class BaseController < ApplicationController
    include Co::DemoFactoryBot
    layout "demo"
  end
end
