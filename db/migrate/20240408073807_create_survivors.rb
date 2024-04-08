class CreateSurvivors < ActiveRecord::Migration[7.0]
  def change
    create_table :survivors do |t|
    	t.string :name
    	t.integer :age
    	t.integer :gender
    	t.decimal :latitude
    	t.decimal :longitude
    	t.boolean :infected, default: false
      
      t.timestamps
    end
  end
end