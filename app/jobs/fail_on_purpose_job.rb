# frozen_string_literal: true

class OnPurposeError < StandardError; end

class FailOnPurposeJob
  include Sidekiq::Job

  sidekiq_retry_in { 30 }

  def perform
    raise OnPurposeError
  end
end
