class ChangeNamespaceActiveAdminComments < ActiveRecord::Migration[7.0]
  def up
    ActiveAdminComment.update_all(namespace: "admin_old")
  end

  def down
    ActiveAdminComment.update_all(namespace: "admin")
  end
end
