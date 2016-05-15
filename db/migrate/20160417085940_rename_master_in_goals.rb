class RenameMasterInGoals < ActiveRecord::Migration
  def change
  	rename_column :goals, :master, :master_id
  end
end
