class AddSecurePayloadToIdentification < ActiveRecord::Migration[5.0]
  def change
    add_column :identifications, :encrypted_payload, :binary
  end
end
