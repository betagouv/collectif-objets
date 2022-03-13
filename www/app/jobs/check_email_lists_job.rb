# frozen_string_literal: true

class CheckEmailListsJob
  include Sidekiq::Job

  CHECKS = {
    "cold" => {
      user_func: ->(user) { user.commune.status.blank? }
    },
    "enrolled" => {
      user_func: ->(user) { user.commune.enrolled? }
    },
    "completed" => {
      user_func: lambda { |user|
        user.commune.completed? && user.commune.objets.where_assoc_exists(%i[recensements photos_attachments]).any?
      }
    },
    "missing-photos" => {
      user_func: lambda { |user|
        user.commune.completed? && user.commune.objets.where_assoc_exists(%i[recensements photos_attachments]).none?
      }
    }
  }.freeze

  def perform(departement = nil)
    @departement = departement
    report_data = departements.map { [_1, check_departement(_1)] }.to_h
    AdminMailer.emails_report(report_data).deliver_now
  end

  protected

  def departements
    @departement ? [@departement] : Commune.select(:departement).distinct.map(&:departement).compact
  end

  def check_departement(departement)
    CHECKS.to_h do |list_key, check_data|
      list = Co::SendInBlueClient.instance.get_list(departement, list_key)
      [list_key, {
        "list_name" => list.name,
        "list_id" => list.id,
        "list_members_count" => list.total_subscribers,
        **check(departement, list_key, check_data[:user_func]).stringify_keys
      }]
    end
  end

  def check(departement, name, user_cond)
    user_pairs = get_user_pairs(departement, name)
    not_found_in_db = user_pairs.select { _1[:user].nil? }
      .map { serialize_pair(_1) }
    should_not_be_in_list = user_pairs
      .select { _1[:user].present? }
      .reject { user_cond.call(_1[:user]) }
      .map { serialize_pair(_1) }
    # missing_from_list = User.includes(:commune)
    #   .where(commune: { departement:, status: nil })
    #   .exclude { contacts.includes(_1.email) }
    #   .map { serialize_user(_1) }
    { not_found_in_db:, should_not_be_in_list: }
  end

  def get_user_pairs(departement, name)
    sib_contacts = Co::SendInBlueClient.instance.get_list_contacts(departement, name)
    users = User.where(email: sib_contacts.pluck(:email)).includes(:commune).to_a
    sib_contacts.map do |sib_contact|
      {
        sib_contact:,
        user: users.find { _1.email == sib_contact[:email] }
      }
    end
  end

  def serialize_pair(pair)
    {
      "email" => pair[:sib_contact][:email],
      "sib_id" => pair[:sib_contact][:id]
    }.merge(pair[:user] ? serialize_user(pair[:user]) : {})
  end

  def serialize_user(user)
    {
      "commune_id" => user.commune.id,
      "commune_status" => user.commune.status,
      "recensements_count" => user.commune.objets.where_assoc_exists(:recensements).count,
      "recensements_with_photos_count" => user.commune.objets
        .where_assoc_exists(%i[recensements photos_attachments])
        .count
    }
  end
end
