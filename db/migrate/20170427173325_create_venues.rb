class CreateVenues < ActiveRecord::Migration[5.0]
  def change
    create_table :venues do |t|
      t.string :name
      t.string :drinkcommand_id
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal
      t.text :location
      t.text :hours

      t.timestamps
    end
    add_index :venues, :drinkcommand_id
  end
end
