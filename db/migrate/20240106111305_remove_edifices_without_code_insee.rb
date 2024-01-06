class RemoveEdificesWithoutCodeInsee < ActiveRecord::Migration[7.1]
  def up
    edifices = Edifice.where(code_insee: nil)
    if edifices.any? { _1.objets.any? }
      raise "ERROR ! Some edifices without code_insee have objets"
    end
    puts "Removing #{edifices.count} edifices without code_insee..."
    edifices.destroy_all
    puts "Done."
  end
end
