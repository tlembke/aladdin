class AddTypeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :recall, :boolean, null: false, default: false
  end
end
