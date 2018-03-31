class AddIndexesToUser < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.index :rfid, unique: true
      t.index :phone_number, unique: true
      t.index :mobile, unique: true
    end
  end
end
