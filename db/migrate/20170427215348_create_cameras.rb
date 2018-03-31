class CreateCameras < ActiveRecord::Migration[5.0]
  def change
    create_table :cameras do |t|
      t.references :venue
      t.integer :style
      t.string :tap_id
      t.string :url
      t.timestamps
    end

    add_index :cameras, :tap_id
    add_foreign_key :cameras, :venues, on_delete: :cascade
  end
end
