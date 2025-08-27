# frozen_string_literal: true

module NotifyRecenseurOfAccessChange
  extend ActiveSupport::Concern

  included do
    after_action :notify_access_change, only: [:create, :update, :destroy]
  end

  private

  def notify_access_change
    if @recenseur.destroyed?
      RecenseurMailer.with(email: @recenseur.email, nom: @recenseur.email).access_revoked.deliver_later
    elsif @recenseur.notify_access_revoked?
      RecenseurMailer.with(recenseur: @recenseur).access_revoked.deliver_later(wait: 5.minutes)
    elsif @recenseur.notify_access_granted?
      RecenseurMailer.with(recenseur: @recenseur).access_granted.deliver_later(wait: 5.minutes)
    end
  end
end
