# frozen_string_literal: true

module Cypress
  class MailsController < ApplicationController
    def last
      sleep 3
      render json: ActionMailer::Base.deliveries.last
    end
  end
end
