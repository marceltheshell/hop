class RemoveDobFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :dob, :date
    remove_column :users, :activated_at, :datetime
    remove_column :users, :balance, :decimal
  end
end
