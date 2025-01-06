# frozen_string_literal: true

module NamespacedPolicies
  extend ActiveSupport::Concern

  def policy(record) = super([namespace, record].flatten.uniq)
  def policy_scope(scope) = super([namespace, scope])
  def authorize(record, query = nil) = super([namespace, record], query)
end
