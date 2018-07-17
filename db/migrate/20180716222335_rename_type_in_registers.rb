class RenameTypeInRegisters < ActiveRecord::Migration
  def change
  	rename_column :registers, :type, :code
  end
end
