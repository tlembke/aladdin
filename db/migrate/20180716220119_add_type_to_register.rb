class AddTypeToRegister < ActiveRecord::Migration
  def change
		add_column :registers, :type, :integer, :null => false, :default => 0
  end
end
