class DropDCid < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :drink_command_id
  end
end
