class AddBookhourToBooker < ActiveRecord::Migration
  def change
    add_column :bookers, :bookhour, :integer
    add_column :bookers, :bookminute, :integer
  end
end
