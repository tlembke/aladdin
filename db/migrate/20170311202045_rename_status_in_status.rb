class RenameStatusInStatus < ActiveRecord::Migration
  def change
  	rename_column :statuses, :status, :progress
  end
end
