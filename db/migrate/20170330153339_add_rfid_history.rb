class AddRfidHistory < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.string :rfid_history, array: true, default: []
      t.index :rfid_history, using: 'gin'
    end
  end
end
