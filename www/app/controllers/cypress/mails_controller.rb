# frozen_string_literal: true

module Cypress
  class MailsController < ApplicationController
    def last
      sleep 0.5
      render json: ActionMailer::Base.deliveries.last
    end
  end
end
