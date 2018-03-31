class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.references :user, foreign_key: true
      t.string :type
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal

      t.timestamps
    end
  end
end
