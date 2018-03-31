class AddFieldsToUserTransaction < ActiveRecord::Migration[5.0]
  def change
    add_column :user_transactions, :employee_id, :string
    add_index :user_transactions, :employee_id
    add_column :user_transactions, :venue_id, :string
    add_column :user_transactions, :tap_id, :string
    add_column :user_transactions, :qty, :integer
  end
end
