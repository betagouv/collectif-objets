class RemoveTrailingSpacesFromObjetsPalissyFields < ActiveRecord::Migration[7.1]
  def up
    %w[palissy_TICO palissy_EDIF palissy_EMPL palissy_DPRO palissy_SCLE palissy_CATE palissy_REFA].each do |field|
      Objet.where(%["#{field}" LIKE '% ']) # ending with a space
        .or(Objet.where(%["#{field}" LIKE ' %'])) # starting with a space
        .or(Objet.where(%["#{field}" ~ E'.*\\n'])) # ending with a newline
        .find_each do |objet|
        objet.update_column(field, objet.send(field).strip)
      end
    end
  end

  def down
    # no-op
  end
end
