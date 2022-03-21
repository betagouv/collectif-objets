# frozen_string_literal: true

class FillMissingMagicTokensJob
  include Sidekiq::Job

  def perform(departement)
    User
      .joins(:commune)
      .where(communes: { departement: })
      .where(magic_token: nil)
      .find_each { rotate_magic_token(_1) }
  end

  protected

  def rotate_magic_token(user)
    user.update_columns(magic_token: SecureRandom.hex(10))
    Sidekiq.logger.info "added magic token to #{user.email}"
  end
end
