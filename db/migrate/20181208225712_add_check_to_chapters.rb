class AddCheckToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :check, :boolean, :null => false, :default => false
  end
end
