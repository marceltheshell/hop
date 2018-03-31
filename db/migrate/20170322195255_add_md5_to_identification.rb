class AddMd5ToIdentification < ActiveRecord::Migration[5.0]
  def change
    change_table :identifications do |t|
      t.string :number_md5
      t.index :number_md5, unique: true
    end
  end
end
