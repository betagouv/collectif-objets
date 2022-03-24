class ChangeCommuneStatusDefault < ActiveRecord::Migration[7.0]
  def up
    change_column_default :communes, :status, from: nil, to: Commune::STATUS_INACTIVE
    change_column_null :communes, :status, false, Commune::STATUS_INACTIVE
  end
end
