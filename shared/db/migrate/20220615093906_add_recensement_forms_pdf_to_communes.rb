class AddRecensementFormsPdfToCommunes < ActiveRecord::Migration[7.0]
  def change
    add_column :communes, :recensement_forms_pdf_updated_at, :datetime
  end
end
