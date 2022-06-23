class ChangeCommuneStatusDefault < ActiveRecord::Migration[7.0]
  def up
    change_column_default :communes, :status, from: nil, to: Commune::STATE_INACTIVE
    change_column_null :communes, :status, false, Commune::STATE_INACTIVE
  end
end
