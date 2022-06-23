# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # this allows events to be called with additional updates
  # it would be better as a aasm_fire_event within the transaction + assign_attributes so
  # it is atomic, but it does not seem to work
  def aasm_after_commit_update(updates = {})
    update!(updates) if updates.any?
  end
end
