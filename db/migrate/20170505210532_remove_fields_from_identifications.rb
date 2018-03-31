class RemoveFieldsFromIdentifications < ActiveRecord::Migration[5.0]
  def change
    change_table :identifications do |t|
      t.remove :number_md5
    end
  end
end
