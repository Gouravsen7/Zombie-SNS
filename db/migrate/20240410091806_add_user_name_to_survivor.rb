class AddUserNameToSurvivor < ActiveRecord::Migration[7.0]
  def change
  	add_column :survivors, :user_name, :string
  end
end
