class AddSecurePayloadToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :encrypted_payload, :binary
  end
end
