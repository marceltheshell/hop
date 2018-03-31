class DropUniqueIndexes < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.remove_index :email   # drops the unique index
      t.remove_index :phone   # drops the unique index
      
      t.index :email          # creates standard index
      t.index :phone          # creates standard index
    end
  end
end
