class AddPriorityToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :priority, :boolean
  end
end
