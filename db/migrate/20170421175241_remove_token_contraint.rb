class RemoveTokenContraint < ActiveRecord::Migration[5.0]
  def change
    change_table :payment_methods do |t|
      t.remove_index :token
    end
  end
end
