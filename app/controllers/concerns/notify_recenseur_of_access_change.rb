# frozen_string_literal: true

module NotifyRecenseurOfAccessChange
  extend ActiveSupport::Concern

  included do
    after_action :notify_access_granted, only: [:create, :update]
    after_action :notify_access_revoked, only: :destroy
  end

  private

  def notify_access_granted
    return unless @recenseur.notify_access_granted?

    RecenseurMailer.with(recenseur: @recenseur).access_granted.deliver_later(wait: 5.minutes)
  end

  def notify_access_revoked
    return unless @recenseur.destroyed? # Ne rien envoyer tant que le recenseur n'est pas supprimé

    RecenseurMailer.with(email: @recenseur.email, nom: @recenseur.email).access_revoked.deliver_later
  end
end
