class RenameIdentifier < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.remove :identifier
      t.uuid :drink_command_id, default: 'uuid_generate_v4()'
      t.index :drink_command_id, unique: true
    end
  end
end
