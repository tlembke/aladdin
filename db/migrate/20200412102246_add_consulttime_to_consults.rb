class AddConsulttimeToConsults < ActiveRecord::Migration
  def change
    add_column :consults, :consulttime, :integer
    add_column :consults, :delivery, :integer
  end
end
