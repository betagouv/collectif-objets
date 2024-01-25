# frozen_string_literal: true

class OnPurposeError < StandardError; end

class FailOnPurposeJob < ApplicationJob
  retry_on StandardError, Exception, wait: 30, attempts: 5

  def perform
    raise OnPurposeError
  end
end
