class AddSortToHeaders < ActiveRecord::Migration
  def change
    add_column :headers, :sort, :integer
  end
end
