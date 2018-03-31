class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.belongs_to :user, null: false
      t.belongs_to :user_transaction
      t.uuid :dc_uuid, null: false
      t.jsonb :payload, null: false, default: {}
      t.integer :status, default: 0
      t.timestamps

      t.index :dc_uuid, unique: true
    end
  end
end
