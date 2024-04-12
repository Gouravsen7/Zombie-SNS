class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :item
      t.integer :points
      t.integer :quantity
      t.references :survivor

      t.timestamps
    end
    execute "ALTER TABLE items ADD CONSTRAINT quantity CHECK ((quantity > 0 AND item IN ('water', 'first aid')) OR (quantity >= 0 AND item IN ('soup', 'ak47')))"
  end
end
