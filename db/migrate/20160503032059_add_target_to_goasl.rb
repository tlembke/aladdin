class AddTargetToGoasl < ActiveRecord::Migration
  def change
  	add_column :goals, :target, :decimal
  end
end
