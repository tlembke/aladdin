class AddMasterToGoals < ActiveRecord::Migration
  def change
  	add_column :goals, :master, :integer
  end
end
