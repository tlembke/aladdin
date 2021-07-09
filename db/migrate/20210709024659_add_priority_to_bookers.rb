class AddPriorityToBookers < ActiveRecord::Migration
  def change
    add_column :bookers, :priority, :integer, default: 0
  end
end
