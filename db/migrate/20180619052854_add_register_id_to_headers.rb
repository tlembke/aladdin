class AddRegisterIdToHeaders < ActiveRecord::Migration
  def change
    add_column :headers, :register_id, :integer
  end
end
