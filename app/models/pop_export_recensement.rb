# frozen_string_literal: true

class PopExportRecensement < ApplicationRecord
  belongs_to :pop_export
  belongs_to :recensement
end
