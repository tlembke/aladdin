class ChangePosition < ActiveRecord::Migration
  def change
  	rename_column :chapters, :position, :sort
  end
end
