class CreateReportedSurvivors < ActiveRecord::Migration[7.0]
  def change
    create_table :reported_survivors do |t|
    	t.integer :reported_to
    	t.integer :reported_by
    	
      t.timestamps
    end
  end
end
