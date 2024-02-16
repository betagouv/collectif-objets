# frozen_string_literal: true

module Synchronizer
  module LogConcern
    extend ActiveSupport::Concern

    included do
      private

      attr_reader :logger

      delegate :log, to: :logger, allow_nil: true
      # allow_nil is useful in tests
    end
  end
end
