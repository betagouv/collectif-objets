require 'csv'

class CreateEdifices < ActiveRecord::Migration[7.0]
  def up
    create_table :edifices do |t|
      t.string :merimee_REF, index: true
      t.string :code_insee, index: true
      t.string :nom
      t.string :merimee_PRODUCTEUR
      t.string :slug

      t.timestamps
    end
    add_reference :objets, :edifice

    add_column :objets, :tmp_edifice_slug, :string

    fill_objets_tmp_edifice_slug
    create_empty_merimee_edifices
    synchronize_merimee_edifices
    link_objets_to_merimee_edifices
    create_custom_edifices
    link_objets_to_custom_edifices
    puts "finished ! there are still #{Objet.where(edifice_id: nil).count} objets without an edifice :("
    remove_column :objets, :tmp_edifice_slug
  end

  def down
    remove_reference :objets, :edifice
    drop_table :edifices
  end

  private

  def fill_objets_tmp_edifice_slug
    start_step 1, "fill objets tmp_edifice_slug"
    with_progressbar(total: Objet.count) do |progressbar|
      Objet.select(:id, :palissy_EDIF).find_each do |objet|
        objet.update_column(:tmp_edifice_slug, Edifice.slug_for(objet.palissy_EDIF))
        progressbar.increment
      end
    end
    puts "done! tmp_edifice_slug filled"
  end

  def create_empty_merimee_edifices
    refs = Objet.select(:palissy_REFA).distinct.pluck(:palissy_REFA).compact
    start_step 2, "will create #{refs.count} edifices (#{refs.first(3).to_sentence})"
    with_progressbar(total:refs.count) do |progressbar|
      refs.each do |merimee_REF|
        Edifice.create!(merimee_REF:)
        progressbar.increment
      end
    end
    puts "done creating #{refs.count} Merimee edifices!\n"
  end

  def synchronize_merimee_edifices
    start_step 3, "will synchronize #{Edifice.count} merimee edifices with datasette API..."
    Synchronizer::SynchronizeEdificesJob.perform_inline
    puts "done synchronizing #{Edifice.count} merimee edifices with datasette API!"
  end

  def link_objets_to_merimee_edifices
    start_step 4, "will try to set edifice_id on all objets with a REFA that is a valid Merimee edifice..."
    edifices = Edifice.where.not(code_insee: nil)
    puts "will go through #{edifices.count} edifices..."
    with_progressbar(total: edifices.count) do |progressbar|
      edifices.find_each do |edifice|
        Objet
          .where(palissy_REFA: edifice.merimee_REF, palissy_INSEE: edifice.code_insee)
          .update_all(edifice_id: edifice.id)
        progressbar.increment
      end
    end
    puts "done! could link #{Objet.where.not(edifice_id: nil).count} objets to Merimee edifices.\n"
  end

  def create_custom_edifices
    start_step 5, "will now create the missing edifices based on palissy names..."
    puts "about to create #{custom_edifices_rows.count} edifices #{custom_edifices_rows.first(3)}..."
    with_progressbar(total: custom_edifices_rows.count) do |progressbar|
      custom_edifices_rows.each do |raw|
        progressbar.increment
        Edifice.create!(raw.slice(:code_insee, :slug, :nom))
      end
    end
    puts "done! created #{custom_edifices_rows.count} edifices based on palissy names\n"
  end


  def link_objets_to_custom_edifices
    start_step 6, "will set edifice_id individually on all objets..."
    edifices = Edifice.where.not(slug: nil)
    with_progressbar(total: edifices.count) do |progressbar|
      edifices.find_each do |edifice|
        Objet
          .where(palissy_INSEE: edifice.code_insee, tmp_edifice_slug: edifice.slug)
          .update_all(edifice_id: edifice.id)
        progressbar.increment
      end
    end
    puts "done setting edifice_id on most objets!\n"
  end

  def with_progressbar(total:)
    progressbar = ProgressBar.create(total:, format: "%t: |%B| %p%% %e")
    arel_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    yield progressbar
    ActiveRecord::Base.logger = arel_logger
  end

  def custom_edifices_rows
    @custom_edifices_rows ||= compute_custom_edifice_rows
  end

  def compute_custom_edifice_rows
    arr = {}
    existing_by_code_insee = Edifice.pluck(:code_insee, :slug).group_by { _1[0] }
    Objet
      .where(edifice_id: nil)
      .where.not(palissy_INSEE: nil)
      .select(:id, :palissy_INSEE, :tmp_edifice_slug, :palissy_EDIF)
      .find_each do |objet|
        key = [objet.palissy_INSEE, objet.tmp_edifice_slug]
        next if existing_by_code_insee[objet.palissy_INSEE]&.include?(key)
        arr[key] ||= { code_insee: objet.palissy_INSEE, nom: objet.palissy_EDIF, slug: objet.tmp_edifice_slug }
      end
    arr.values
  end

  def start_step(number, message)
    puts "STEP #{number}"
    puts message
    sleep 1
  end

  # Edifice.find_each { link_edifice_communes(_1) }

end
