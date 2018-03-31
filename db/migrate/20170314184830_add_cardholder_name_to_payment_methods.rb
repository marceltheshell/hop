class AddCardholderNameToPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_methods, :cardholder_name, :string
    add_column :payment_methods, :token, :string
  end
end
