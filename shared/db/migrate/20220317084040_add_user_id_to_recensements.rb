class AddUserIdToRecensements < ActiveRecord::Migration[7.0]
  def up
    add_reference :recensements, :user, foreign_key: true
    Recensement.where(user_id: nil).each do |recensement|
      user = recensement.commune.users.first
      raise "missing user for recensement #{recensement.id} on objet #{recensement.objet.ref_pop}, commune #{recensement.commune.nom} (#{recensement.commune.code_insee})" if user.nil?

      recensement.update_columns(user_id: user.id)
    end
    change_column_null :recensements, :user_id, false
  end

  def down
    remove_reference :recensements, :user, foreign_key: true
  end
end

recensements_without_users = Recensement.all.filter { _1.commune&.users&.empty? }
