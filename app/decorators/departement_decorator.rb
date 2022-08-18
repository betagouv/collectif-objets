# frozen_string_literal: true

class DepartementDecorator < Draper::Decorator
  delegate_all

  delegate :count, to: :communes, prefix: true

  delegate :count, to: :objets, prefix: true
end
