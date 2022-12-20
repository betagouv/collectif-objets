class AddMemoirePhotosSequences < ActiveRecord::Migration[7.0]
  def up
    add_column :active_storage_attachments, :memoire_number, :integer
    ActiveRecord::Base.connection.execute \
      sequence_names.map { "CREATE SEQUENCE IF NOT EXISTS #{_1};" }.join("\n")
    progress = ProgressBar.create(total: attachments.count, format: "%t: |%B| %p%% %e")
    attachments.each do |attachment|
      attachment.set_memoire_number
      progress.increment
    end
  end

  def down
    remove_column :active_storage_attachments, :memoire_number, :int
    ActiveRecord::Base.connection.execute \
      sequence_names.map { "DROP SEQUENCE #{_1};" }.join("\n")
  end

  private

  def sequence_names
    Departement.order(:code).map(&:memoire_sequence_name)
  end

  def attachments
    ActiveStorage::Attachment
      .where(record_type: "Recensement")
      .includes(:recensement)
  end
end
