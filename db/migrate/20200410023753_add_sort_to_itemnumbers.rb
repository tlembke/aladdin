class AddSortToItemnumbers < ActiveRecord::Migration
  def change
    add_column :itemnumbers, :sort, :integer
  end
end
