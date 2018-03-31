class ChangePaymentMethod < ActiveRecord::Migration[5.0]
  def up
    change_table :payment_methods do |t|
      t.change :token, :string, null: false
      t.remove :payment_type
      t.remove :is_primary
      t.remove :is_multiuse
      
      t.index :token, unique: true
    end
  end

  def down
    change_table :payment_methods do |t|
      t.change :token, :string, null: true
      t.string :payment_type
      t.boolean :is_primary
      t.boolean :is_multiuse
      
      t.remove_index :token
    end
  end
end
