class AddColumnToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pin, :string
    add_index  :users, :pin
  end
end
