# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def validate_email
    user = User.new(email: "mairie@thoiry.fr", login_token: "a1r2b95")
    user.readonly!
    UserMailer.validate_email(user)
  end

  def commune_completed_email
    user_id = User.order(Arel.sql("RANDOM()")).first.id
    commune_id = Commune.order(Arel.sql("RANDOM()")).first.id
    UserMailer.with(user_id:, commune_id:).commune_completed_email
  end
end
