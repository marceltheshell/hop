class AddEncryptedPayloadToPaymentMethods < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_methods, :encrypted_payload, :binary
  end
end
