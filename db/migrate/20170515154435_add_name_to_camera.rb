class AddNameToCamera < ActiveRecord::Migration[5.0]
  def change
    add_column :cameras, :name, :string
  end
end
