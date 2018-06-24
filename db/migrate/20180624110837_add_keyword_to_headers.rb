class AddKeywordToHeaders < ActiveRecord::Migration
  def change
    add_column :headers, :keyword, :string
  end
end
