class CreatePaymentMethods < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_methods do |t|
      t.references :user, foreign_key: true
      t.string :type
      t.string :payment_type
      t.string :vendor_name
      t.string :masked_card_number
      t.date :expiration_date
      t.integer :cvv
      t.boolean :is_primary
      t.boolean :is_multiuse

      t.timestamps
    end
  end
end
