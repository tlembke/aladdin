class AddAutoloadToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :autoload, :string
  end
end
