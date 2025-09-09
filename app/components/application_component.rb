# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  private

  # Forward namespace logic from ApplicationController
  # Only return valid routing namespaces that match controller namespaces
  VALID_NAMESPACES = [:admin, :communes, :conservateurs, :recenseurs].freeze

  def namespaced? = self.class.name.include?("::")

  def namespace
    return nil unless namespaced?

    candidate = self.class.module_parent.to_s.downcase.to_sym
    VALID_NAMESPACES.include?(candidate) ? candidate : nil
  end
end
