class ChangeType < ActiveRecord::Migration[5.0]
  def change
    rename_column :addresses, :type, :address_type
    rename_column :identifications, :type, :identification_type
    remove_column :payment_methods, :type, :string
  end
end
