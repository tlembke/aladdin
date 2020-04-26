class AddByToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :by, :text
    add_column :goals, :fallback1, :text
    add_column :goals, :fallback2, :text
  end
end
