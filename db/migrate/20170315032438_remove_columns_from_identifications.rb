class RemoveColumnsFromIdentifications < ActiveRecord::Migration[5.0]
  def change
    remove_column :identifications, :photo_url, :string
    remove_column :identifications, :issuer, :string
    remove_column :identifications, :id_number, :string
    remove_column :identifications, :expires_at, :date
  end
end
