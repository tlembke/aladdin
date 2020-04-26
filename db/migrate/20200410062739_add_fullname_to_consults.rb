class AddFullnameToConsults < ActiveRecord::Migration
  def change
    add_column :consults, :fullname, :string
  end
end
