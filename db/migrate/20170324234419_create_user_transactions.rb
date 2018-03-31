class CreateUserTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_transactions do |t|
      t.references :user, foreign_key: true
      t.string :type
      t.string :description
      t.integer :amount_in_cents
      t.integer :balance_in_cents
      t.jsonb :metadata
      t.datetime :created_at

      t.timestamps
    end
    add_index :user_transactions, :type
    add_index :user_transactions, :created_at
  end
end
