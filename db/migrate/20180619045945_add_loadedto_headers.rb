class AddLoadedtoHeaders < ActiveRecord::Migration
  def change
  	add_column :headers, :loaded, :datetime
  end
end
