class AddLoadedToRegisters < ActiveRecord::Migration
  def change
    add_column :registers, :loaded, :datetime
  end
end
