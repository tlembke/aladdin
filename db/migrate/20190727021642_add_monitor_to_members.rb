class AddMonitorToMembers < ActiveRecord::Migration
  def change
    add_column :members, :everyNumber, :integer
    add_column :members, :everyUnit, :string
    add_column :members, :nextDay, :integer
    add_column :members, :nextMonth, :integer
    add_column :members, :nextYear, :integer
  end
end
