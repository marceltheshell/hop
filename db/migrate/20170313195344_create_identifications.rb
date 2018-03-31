class CreateIdentifications < ActiveRecord::Migration[5.0]
  def change
    create_table :identifications do |t|
      t.references :user, foreign_key: true
      t.string :type
      t.string :issuer
      t.string :id_number
      t.date :expires_at
      t.string :photo_url

      t.timestamps
    end
  end
end
