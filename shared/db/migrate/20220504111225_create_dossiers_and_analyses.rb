class CreateDossiersAndAnalyses < ActiveRecord::Migration[7.0]
  def up
    create_table :dossiers do |t|
      t.references :commune, null: false, foreign_key: true, unique: true, index: { unique: true, name: "dossiers_unique_commune_id"}
      t.string :status, default: "construction", null: false
      t.datetime :submitted_at
      t.datetime :rejected_at
      t.datetime :accepted_at
      t.datetime :pdf_updated_at
      t.string :notes_commune
      t.string :notes_conservateur
      t.string :notes_conservateur_private
      t.references :conservateur

      t.timestamps
    end

    add_column :objets, :notes_conservateur, :string
    add_reference :objets, :conservateurs

    add_column :recensements, :analyse_etat_sanitaire, :string
    add_column :recensements, :analyse_etat_sanitaire_edifice, :string
    add_column :recensements, :analyse_securisation, :string
    add_column :recensements, :analyse_actions, :string, array: true, default: []
    add_column :recensements, :analyse_fiches, :string, array: true, default: []
    add_column :recensements, :analyse_notes, :text
    add_column :recensements, :analyse_prioritaire, :boolean
    add_column :recensements, :analysed_at, :datetime
    add_reference :recensements, :conservateur
    add_reference :recensements, :dossier

    add_reference :communes, :dossier

    Commune.joins(:recensements).distinct.find_each do |commune|
      puts "attaching commune #{commune.code_insee}'s #{commune.recensements.count} recensements to new dossier"
      dossier = Dossier.create!(
        commune_id: commune.id,
        status: commune.completed? ? "submitted" : "construction",
        submitted_at: commune.completed? && commune.completed_at || Time.now,
        notes_commune: commune.notes_from_completion.presence
      )
      raise(dossier.errors.full_messages.join) unless dossier.valid?
      commune.recensements.update_all(dossier_id: dossier.id)
    end

    communes_dossier_id_pairs = Dossier.includes(:commune).map do |dossier|
      [dossier.commune.id, dossier.id]
    end
    communes_dossier_id_pairs.each do |commune_id, dossier_id|
      puts "updating commune #{commune_id} with dossier #{dossier_id}"
      Commune.where(id: commune_id).update_all(dossier_id:, notes_from_completion: nil)
    end
    puts "#{Commune.where.not(dossier_id: nil).count} communes have a dossier_id"

    raise if Commune.where.not(notes_from_completion: [nil, ""]).any?
    remove_column :communes, :notes_from_completion

    change_column_null :recensements, :dossier_id, false
  end

  def down
    remove_column :communes, :dossier_id

    add_column :communes, :notes_from_completion, :string
    Dossier.where.not(notes_commune: nil).find_each do |dossier|
      dossier.commune.update!(notes_from_completion: dossier.notes_commune)
    end
    drop_table :dossiers

    remove_column :objets, :notes_conservateur
    remove_reference :objets, :conservateurs

    remove_column :recensements, :dossier_id
    remove_column :recensements, :conservateur_id
    remove_column :recensements, :analyse_etat_sanitaire
    remove_column :recensements, :analyse_etat_sanitaire_edifice
    remove_column :recensements, :analyse_securisation
    remove_column :recensements, :analyse_actions
    remove_column :recensements, :analyse_fiches
    remove_column :recensements, :analyse_notes
    remove_column :recensements, :analyse_prioritaire
    remove_column :recensements, :analysed_at
  end

end
