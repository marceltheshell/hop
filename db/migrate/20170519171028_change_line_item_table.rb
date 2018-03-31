class ChangeLineItemTable < ActiveRecord::Migration[5.0]
  def change
    change_column :line_items, :user_id, :int, :null => true
  end
end
