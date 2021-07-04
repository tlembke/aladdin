class AddInviteToBookers < ActiveRecord::Migration
  def change
    add_column :bookers, :invite, :boolean, default: false
    add_column :bookers, :medicare, :string
    add_column :bookers, :medicaremonth, :integer
    add_column :bookers, :medicareyear, :integer
  end
end
