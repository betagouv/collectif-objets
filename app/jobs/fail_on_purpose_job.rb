# frozen_string_literal: true

class FailOnPurposeJob < ApplicationJob
  class OnPurposeError < StandardError; end

  retry_on StandardError, Exception, wait: 30, attempts: 5

  def perform
    raise OnPurposeError
  end
end
