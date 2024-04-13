class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :item
      t.integer :points
      t.integer :quantity
      t.references :survivor

      t.timestamps
    end
  end
end
