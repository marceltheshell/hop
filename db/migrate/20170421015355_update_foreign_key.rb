class UpdateForeignKey < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :addresses, :users
    remove_foreign_key :identifications, :users
    remove_foreign_key :payment_methods, :users
    remove_foreign_key :user_transactions, :users

    add_foreign_key :addresses, :users, on_delete: :cascade
    add_foreign_key :identifications, :users, on_delete: :cascade
    add_foreign_key :payment_methods, :users, on_delete: :cascade
    add_foreign_key :user_transactions, :users, on_delete: :cascade
  end
end
