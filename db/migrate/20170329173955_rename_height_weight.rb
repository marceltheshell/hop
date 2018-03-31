class RenameHeightWeight < ActiveRecord::Migration[5.0]
  def change
    change_table :users do |t|
      t.rename :height, :height_in_cm
      t.rename :weight, :weight_in_kg
    end
  end
end
