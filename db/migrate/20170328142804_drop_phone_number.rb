class DropPhoneNumber < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.remove_index :phone_number
      t.remove_index :mobile
      t.remove :mobile
      t.rename :phone_number, :phone
      t.index :phone, unique: true
    end
  end
end
