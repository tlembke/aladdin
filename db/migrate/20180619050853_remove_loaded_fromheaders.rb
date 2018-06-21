class RemoveLoadedFromheaders < ActiveRecord::Migration
  def change
  	remove_column :headers, :loaded
  end
end
