class AddProvidernameToConsults < ActiveRecord::Migration
  def change
    add_column :consults, :providername, :string
  end
end
