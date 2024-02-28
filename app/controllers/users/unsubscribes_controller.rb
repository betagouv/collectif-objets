# frozen_string_literal: true

module Users
  class UnsubscribesController < ApplicationController
    before_action :set_recipient

    def new; end

    def create
      if @recipient.update(opt_out: true, opt_out_reason: "other")
        redirect_to \
          root_path,
          notice: "#{@recipient.commune.nom} a été désinscrite de la campagne de recensement " \
                  "se terminant le #{l(@campaign.date_fin)}."
      else
        render :new
      end
    end

    private

    def set_recipient
      @recipient = CampaignRecipient.find_by(unsubscribe_token: params[:token])
      @campaign = @recipient&.campaign

      if @recipient.nil? || !@campaign.ongoing?
        redirect_to root_path, alert: "Ce lien de désinscription n’est plus valide"
      elsif @recipient.opt_out?
        redirect_to root_path, alert: "#{@recipient.commune.nom} est déjà désinscrite"
      end
    end
  end
end
