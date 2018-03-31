class AddImageUrl < ActiveRecord::Migration[5.0]

  def up
    change_table :identifications do |t|
      t.uuid :image_id
    end

    change_table :users do |t|
      t.uuid :image_id
      t.date :dob
      t.remove :encrypted_payload
    end
  end

  def down
    change_table :identifications do |t|
      t.remove :image_id
    end

    change_table :users do |t|
      t.remove :image_id
      t.remove :dob
      t.binary :encrypted_payload
    end
  end
end
