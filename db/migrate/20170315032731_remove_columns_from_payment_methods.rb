class RemoveColumnsFromPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    remove_column :payment_methods, :vendor_name, :string
    remove_column :payment_methods, :masked_card_number, :string
    remove_column :payment_methods, :expiration_date, :date
    remove_column :payment_methods, :cvv, :integer
    remove_column :payment_methods, :cardholder_name, :string
  end
end
