# frozen_string_literal: true

class OnPurposeError < StandardError; end

class HealthController < ApplicationController
  def raise_on_purpose
    raise OnPurposeError, "this is no good"
  end
end
