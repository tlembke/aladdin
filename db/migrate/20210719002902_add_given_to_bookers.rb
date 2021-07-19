class AddGivenToBookers < ActiveRecord::Migration
  def change
    add_column :bookers, :given, :boolean, default: false
  end
end
