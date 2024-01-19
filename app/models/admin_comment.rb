# frozen_string_literal: true

class AdminComment < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :author, polymorphic: true
end
