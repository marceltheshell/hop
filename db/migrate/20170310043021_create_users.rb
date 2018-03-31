class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.citext :email, null: false
      t.string :identifier
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.float :height
      t.float :weight
      t.string :gender
      t.date :dob
      t.string :phone_number
      t.string :password_digest
      t.string :photo_url
      t.timestamp :activated_at
      t.timestamp :deactivated_at
      t.decimal :balance
      t.string :rfid
      t.timestamps

      t.index :email, unique: true
    end
  end
end
