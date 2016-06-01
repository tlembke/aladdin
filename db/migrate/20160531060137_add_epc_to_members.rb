class AddEpcToMembers < ActiveRecord::Migration
  def change
    add_column :members, :year_reset, :integer
    add_column :members, :epc, :integer
  end
end
