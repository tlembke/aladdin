class AddExactDateToMembers < ActiveRecord::Migration
  def change
    add_column :members, :exactDate, :boolean
  end
end
